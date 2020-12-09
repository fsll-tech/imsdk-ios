//
//  QIMHTTPClient.m
//  QIMKitVendor
//
//  Created by 李露 on 2018/8/2.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMHTTPClient.h"
#import "QIMHTTPResponse.h"
//#import "ASIHTTPRequest.h"
//#import "ASIFormDataRequest.h"
#import "QIMJSONSerializer.h"
#import "QIMWatchDog.h"
#import "QIMPublicRedefineHeader.h"
#import "QIMHttpRequestManager.h"
#import "QIMHttpRequestConfig.h"
static NSString *baseUrl = nil;

@implementation QIMHTTPClient

+ (NSString *)baseUrl {
    return baseUrl;
}

+ (void)configBaseUrl:(NSString *)httpBaseurl {
    if (httpBaseurl.length > 0) {
        baseUrl = httpBaseurl;
    }
}

+ (void)sendRequest:(QIMHTTPRequest *)request complete:(QIMCompleteHandler)completeHandler failure:(QIMFailureHandler)failureHandler {
    [self sendRequest:request progressBlock:nil complete:completeHandler failure:failureHandler];
}

+ (void)sendRequest:(QIMHTTPRequest *)request progressBlock:(QIMProgressHandler)progreeBlock complete:(QIMCompleteHandler)completeHandler failure:(QIMFailureHandler)failureHandler {
    if (request.url.absoluteString.length <= 0 || request.url.absoluteString == nil) {
        if (failureHandler) {
            failureHandler([NSError errorWithDomain:@"Empty Url String" code:0 userInfo:nil]);
        }
        return;
    }
    
    if (request.uploadComponents.count > 0 || request.postParams || request.HTTPBody) {
        request.HTTPMethod = QIMHTTPMethodPOST;
    }
    if (request.HTTPMethod == QIMHTTPMethodGET) {
        [QIMHTTPClient postAFMethodRequest:request progressBlock:progreeBlock complete:completeHandler failure:failureHandler];
    } else if (request.HTTPMethod == QIMHTTPMethodPOST) {
         [QIMHTTPClient postAFMethodRequest:request progressBlock:progreeBlock complete:completeHandler failure:failureHandler];
    } else {
        
    }
}

+ (void)postAFMethodRequest:(QIMHTTPRequest *)request
              progressBlock:(QIMProgressHandler)progreeBlock
                   complete:(QIMCompleteHandler)completeHandler
                    failure:(QIMFailureHandler)failureHandler {
    
    [[QIMHttpRequestManager sharedManger] sendRequest:^(QIMHTTPRequest * _Nonnull qtRequest) {
        qtRequest.url = request.url;
        qtRequest.httpRequestType = request.httpRequestType;
        qtRequest.HTTPMethod = request.HTTPMethod;
        qtRequest.timeoutInterval = (request.timeoutInterval > 0) ? request.timeoutInterval : 60;
        qtRequest.downloadDestinationPath = request.downloadDestinationPath;
        qtRequest.HTTPRequestHeaders = request.HTTPRequestHeaders;
        qtRequest.uploadComponents = request.uploadComponents;
        qtRequest.retryCount = request.retryCount;
        qtRequest.userInfo = request.userInfo;
        qtRequest.uploadComponents = request.uploadComponents;
        qtRequest.requestSerializer = request.requestSerializer;
        qtRequest.responseSerializer = request.responseSerializer;
        if (request.HTTPBody) {
            qtRequest.postParams = [[QIMJSONSerializer sharedInstance] deserializeObject:request.HTTPBody error:nil];
        } else {
            qtRequest.postParams = request.postParams;
        }
        QIMVerboseLog(@"qtRequest : %@", qtRequest);
    } progressBLock:^(NSProgress *progress) {
        QIMVerboseLog(@"progress : %@", progress);
        if (progreeBlock) {
            progreeBlock(progress);
        }
    } successBlock:^(id  _Nullable responseObjcet, NSInteger httpCode) {
        QIMVerboseLog(@"AFNetWorkingRebuid:%@,  request : %@",responseObjcet, request);
        QIMHTTPResponse *response = [[QIMHTTPResponse alloc] init];
        response.data = responseObjcet;
        response.code = httpCode;
        if ([responseObjcet isKindOfClass:[NSString class]]) {
            response.responseString = responseObjcet;
        } else if ([responseObjcet isKindOfClass:[NSURL class]]) {
            NSURL *filePathUrl = (NSURL *)responseObjcet;
            response.responseString = filePathUrl.absoluteString;
        } else {
            response.responseString = [[NSString alloc] initWithData:responseObjcet encoding:NSUTF8StringEncoding];
        }
        QIMVerboseLog(@"【RequestUrl : %@\n RequestHeader : %@\n Response ( %@ )\n", request.url.absoluteString, request.HTTPRequestHeaders, response);
        if (completeHandler) {
            completeHandler(response);
        }
    } failureBlock:^(NSError *error) {
        if (failureHandler) {
            QIMVerboseLog(@"AFNetWorkingError:%@, request : %@",error, request);
            failureHandler(error);
        }
    } finishBlock:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
    }];
}

/*
+ (void)postMethodRequest:(QIMHTTPRequest *)request
            progressBlock:(QIMProgressHandler)progreeBlock
                 complete:(QIMCompleteHandler)completeHandler
                  failure:(QIMFailureHandler)failureHandler {
    ASIFormDataRequest *asiRequest = [ASIFormDataRequest requestWithURL:request.url];
    [asiRequest setRequestMethod:@"POST"];
    if (request.postParams) {
        for (id key in request.postParams) {
            [asiRequest setPostValue:request.postParams[key] forKey:key];
        }
    } else {
        if (request.HTTPBody) {
            id bodyStr = [[QIMJSONSerializer sharedInstance] deserializeObject:request.HTTPBody error:nil];
            QIMVerboseLog(@"QIMHTTPRequest请求Url : %@, Body :%@,", request.url, bodyStr);
            [asiRequest setPostBody:[NSMutableData dataWithData:request.HTTPBody]];
        }
    }
    if (request.uploadComponents) {
        for (NSInteger i = 0; i < request.uploadComponents.count; i++) {
            QIMHTTPUploadComponent *component = request.uploadComponents[i];
            if (component.filePath) {
                [asiRequest addFile:component.filePath withFileName:component.fileName andContentType:component.mimeType forKey:component.dataKey];
            } else if (component.fileData) {
                [asiRequest addData:component.fileData withFileName:component.fileName andContentType:component.mimeType forKey:component.dataKey];
            }
            NSDictionary *uploadBodyDic = component.bodyDic;
            for (NSString *uploadBodyKey in component.bodyDic.allKeys) {
                [asiRequest addPostValue:[uploadBodyDic objectForKey:uploadBodyKey] forKey:uploadBodyKey];
            }
        }
    }
    [self configureASIRequest:asiRequest QIMHTTPRequest:request progressBlock:progreeBlock complete:completeHandler failure:failureHandler];
    QIMVerboseLog(@"startSynchronous获取当前线程1 :%@, %@",dispatch_get_current_queue(),  request.url);
    CFAbsoluteTime startTime = [[QIMWatchDog sharedInstance] startTime];
    if (request.shouldASynchronous) {
        [asiRequest startAsynchronous];
    } else {
        [asiRequest startSynchronous];
    }
    QIMVerboseLog(@"startSynchronous获取当前线程2 :%@,  %@, %lf", dispatch_get_current_queue(), request.url, [[QIMWatchDog sharedInstance] escapedTimewithStartTime:startTime]);
}
*/

/*
+ (void)configureASIRequest:(ASIHTTPRequest *)asiRequest
              QIMHTTPRequest:(QIMHTTPRequest *)request
              progressBlock:(QIMProgressHandler)progreeBlock
                   complete:(QIMCompleteHandler)completeHandler
                    failure:(QIMFailureHandler)failureHandler {
    [asiRequest setNumberOfTimesToRetryOnTimeout:2];
    [asiRequest setValidatesSecureCertificate:asiRequest.validatesSecureCertificate];
    [asiRequest setTimeOutSeconds:request.timeoutInterval];
    [asiRequest setAllowResumeForFileDownloads:YES];
    if (request.HTTPRequestHeaders) {
        [asiRequest setUseCookiePersistence:NO];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:request.HTTPRequestHeaders];
        [asiRequest setRequestHeaders:dict];
    } else {
        //默认加载Cookie
        [asiRequest setUseCookiePersistence:YES];
    }
    if (request.downloadDestinationPath) { //有下载路径时，认为是下载
        [asiRequest setDownloadDestinationPath:request.downloadDestinationPath];
        [asiRequest setTemporaryFileDownloadPath:request.downloadTemporaryPath];
    }
    __weak typeof(asiRequest) weakAsiRequest = asiRequest;
    asiRequest.completionBlock = ^{
        __strong typeof(weakAsiRequest) strongAsiRequest = weakAsiRequest;
        QIMHTTPResponse *response = [QIMHTTPResponse new];
        response.code = strongAsiRequest.responseStatusCode;
        response.data = strongAsiRequest.responseData;
        response.responseString = strongAsiRequest.responseString;
        QIMVerboseLog(@"【RequestUrl : %@\n RequestHeader : %@\n Response : %@\n", weakAsiRequest.url, weakAsiRequest.requestHeaders, response);
        if (completeHandler) {
            completeHandler(response);
        }
    };
    [asiRequest setFailedBlock:^{
        __strong typeof(weakAsiRequest) strongAsiRequest = weakAsiRequest;
        if (failureHandler) {
            QIMVerboseLog(@"Error : %@", strongAsiRequest.error);
            failureHandler(strongAsiRequest.error);
        }
    }];
    __block long long receiveSize = 0;
    [asiRequest setBytesSentBlock:^(unsigned long long size, unsigned long long total) {
        receiveSize += size;
        float progress = (float)receiveSize/total;
        QIMVerboseLog(@"sent progressValue22 : %lf", progress);
//        if (progreeBlock) {
//            progreeBlock(progress);
//        }
    }];
    [asiRequest setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
        receiveSize += size;
        float progress = (float)receiveSize/total;
        QIMVerboseLog(@"download progressValue : %lf", progress);
//        if (progreeBlock) {
//            progreeBlock(progress);
//        }
    }];
}
*/

+ (void)setCommonRequestConfig:(void (^)(QIMHttpRequestConfig *))configBlock{
    [[QIMHttpRequestManager sharedManger] setQIMHttpRequestConfig:configBlock];
}

@end
