//
//  QIMHttpRequestEngine.m
//  QIMKitVendor
//
//  Created by qitmac000645 on 2019/6/19.
//

#import "QIMHttpRequestEngine.h"
#import "AFURLSessionManager.h"
#import "QIMHTTPRequest.h"
#import "NSURLSessionTask+QIMHttpRequest.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "QIMHttpSerializer.h"

static dispatch_queue_t qim_request_complete_callback_quene() {
    static dispatch_queue_t _qim_request_complete_callback_quene;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _qim_request_complete_callback_quene = dispatch_queue_create("com.qunar.request.completion.callback.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return _qim_request_complete_callback_quene;
}

@interface QIMHttpRequestEngine ()

@property(nonatomic, strong) AFURLSessionManager *sessionManager;
@property(nonatomic, strong) QIMHttpSerializer *serializer;
@end

@implementation QIMHttpRequestEngine


+ (instancetype)shareEngine {
    static QIMHttpRequestEngine *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //[AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        self.serializer = [[QIMHttpSerializer alloc] init];
    }
    return self;
}

+ (void)load {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (AFURLSessionManager *)sessionManager {
    if (!_sessionManager) {
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _sessionManager.operationQueue.maxConcurrentOperationCount = 6;
        _sessionManager.completionQueue = qim_request_complete_callback_quene();
    }
    return _sessionManager;
}


- (void)sendRequest:(QIMHTTPRequest *)request completionHandle:(QIMHttpCompletionHandler)completionHandler {
    if (request.httpRequestType == QIMHTTPRequestTypeNormal) {
        [self normalrequestTaskWithRequest:request completionHandler:completionHandler];
    } else if (request.httpRequestType == QIMHTTPRequestTypeDownload) {
        [self downLoadRequestTaskWithRequest:request completionHandler:completionHandler];
    } else if (request.httpRequestType == QIMHTTPRequestTypeUpload) {
        [self sendUploadRequestTaskWithRequest:request completionHandler:completionHandler];
    } else {

    }
}


- (void)normalrequestTaskWithRequest:(QIMHTTPRequest *)request
                   completionHandler:(QIMHttpCompletionHandler)completionHandler {
    NSString *httpMethdod = nil;
    if (request.HTTPMethod == QIMHTTPMethodGET) {
        httpMethdod = @"GET";
    }
    if (request.HTTPMethod == QIMHTTPMethodPOST) {
        httpMethdod = @"POST";
    }

    AFURLSessionManager *sessionManagater = self.sessionManager;

    id requestSerializer = [self.serializer requestSeialization:request.requestSerializer];
    id responseSerializer = [self.serializer responseSeialization:request.responseSerializer];

    sessionManagater.responseSerializer = responseSerializer;

    NSError *serialziationError = nil;

    NSMutableURLRequest *urlRquest = [requestSerializer requestWithMethod:httpMethdod URLString:request.url.absoluteString parameters:request.postParams error:&serialziationError];

    if (serialziationError) {
        dispatch_async(qim_request_complete_callback_quene(), ^{
            if (completionHandler) {
                completionHandler(nil, -1, serialziationError);
            }
        });
        return;
    }
    [self setUrlHttpRequest:urlRquest WithQImHttpRequest:request];

    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [sessionManagater dataTaskWithRequest:urlRquest
                                                            uploadProgress:nil
                                                          downloadProgress:nil
                                                         completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
                                                             __strong typeof(weakSelf) strongSelf = weakSelf;
                                                             [strongSelf processResponse:response
                                                                          responseObject:responseObject
                                                                                   error:error
                                                                       completionHandler:completionHandler];
                                                         }];
    [self setRequsetIdentifierForRequest:request taskIdentifier:dataTask.taskIdentifier];
    [dataTask setSessionBindRequest:request];
    [dataTask resume];
}

- (void)sendUploadRequestTaskWithRequest:(QIMHTTPRequest *)request completionHandler:(QIMHttpCompletionHandler)completionHandler {

    __block NSError *serializerErr = nil;

    id responseSerializer = [self.serializer responseSeialization:request.responseSerializer];
    id requestSerializer = [self.serializer requestSeialization:request.requestSerializer];

    self.sessionManager.responseSerializer = responseSerializer;
    NSMutableURLRequest *urlRequest = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:request.url.absoluteString parameters:request.postParams constructingBodyWithBlock:^(id <AFMultipartFormData> _Nonnull formData) {
        [request.uploadComponents enumerateObjectsUsingBlock:^(QIMHTTPUploadComponent *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            if (obj.fileData) {
                //上传文件，fileData为文件二进制
                if (obj.mimeType && obj.fileName) {
                    [formData appendPartWithFileData:obj.fileData name:obj.dataKey fileName:obj.fileName mimeType:obj.mimeType];
                } else {
                    [formData appendPartWithFormData:obj.fileData name:obj.dataKey];
                }
            } else if (obj.fileUrl) {
                //上传文件，fileUrl为本地路径
                NSError *fileError = nil;
                if (obj.fileName && obj.mimeType) {
                    [formData appendPartWithFileURL:obj.fileUrl name:obj.dataKey fileName:obj.fileName mimeType:obj.mimeType error:&fileError];
                } else {
                    [formData appendPartWithFileURL:obj.fileUrl name:obj.dataKey error:&fileError];
                }

                if (fileError) {
                    serializerErr = fileError;
                    *stop = YES;
                }
            } else {
                //发送formdata 表单
                NSDictionary *uploadBodyDic = obj.bodyDic;
                for (NSString *uploadBodyKey in obj.bodyDic.allKeys) {
                    [formData appendPartWithFormData:[[uploadBodyDic objectForKey:uploadBodyKey] dataUsingEncoding:NSUTF8StringEncoding] name:uploadBodyKey];
                }
            }
        }];
    }                                                                             error:&serializerErr];

    if (serializerErr) {
        dispatch_async(qim_request_complete_callback_quene(), ^{
            if (completionHandler) {
                completionHandler(nil, -1, serializerErr);
            }
        });
        return;
    }

    [self setUrlHttpRequest:urlRequest WithQImHttpRequest:request];

    NSURLSessionUploadTask *uploadTask = nil;
    __weak typeof(self) weakSelf = self;

    uploadTask = [self.sessionManager uploadTaskWithStreamedRequest:urlRequest progress:request.progressHandler completionHandler:^(NSURLResponse *_Nonnull response, id _Nullable responseObject, NSError *_Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf processResponse:response responseObject:responseObject error:error completionHandler:completionHandler];
    }];

    [self setRequsetIdentifierForRequest:request taskIdentifier:uploadTask.taskIdentifier];
    [uploadTask setSessionBindRequest:request];
    [uploadTask resume];
}

- (void)downLoadRequestTaskWithRequest:(QIMHTTPRequest *)request completionHandler:(QIMHttpCompletionHandler)completionHandler {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:request.url];
    [self setUrlHttpRequest:urlRequest WithQImHttpRequest:request];

    NSURL *downloadFileSavePath;
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:request.downloadDestinationPath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    if (isDirectory) {
        NSString *fileName = [urlRequest.URL lastPathComponent];
        downloadFileSavePath = [NSURL fileURLWithPath:[NSString pathWithComponents:@[request.downloadDestinationPath, fileName]] isDirectory:NO];
    } else {
        downloadFileSavePath = [NSURL fileURLWithPath:request.downloadDestinationPath isDirectory:NO];
    }

    NSURLSessionDownloadTask *task = [self.sessionManager downloadTaskWithRequest:urlRequest progress:request.progressHandler destination:^NSURL *_Nonnull(NSURL *_Nonnull targetPath, NSURLResponse *_Nonnull response) {
        return downloadFileSavePath;
    } completionHandler:^(NSURLResponse *_Nonnull response, NSURL *_Nullable filePath, NSError *_Nullable error) {
        NSHTTPURLResponse *responses = (NSHTTPURLResponse *) response;
        if (completionHandler) {
            completionHandler(filePath, responses.statusCode, error);
        }
    }];
    [self setRequsetIdentifierForRequest:request taskIdentifier:task.taskIdentifier];
    [task setSessionBindRequest:request];
    [task resume];
}


- (void)processResponse:(NSURLResponse *)response responseObject:(id)responseObject error:(NSError *)error completionHandler:(QIMHttpCompletionHandler)completionHandler {
    NSHTTPURLResponse *responses = (NSHTTPURLResponse *) response;
    if (error) {
        NSDictionary *errorInfo = error.userInfo;
        NSInteger errorCode = error.code;
        NSLog(@"=======================requestFailed!!!!=======================");
        NSLog(@"=======================requestUrl:%@=======================", responses.URL.absoluteString);
        NSLog(@"=======================requestErrorCode:%zd=======================", errorCode);
        NSErrorDomain errorDomain = error.domain;
        NSLog(@"=====================%@====================", errorDomain);
        if ([[errorInfo allKeys] containsObject:AFNetworkingOperationFailingURLResponseDataErrorKey]) {
            NSData *errorData = errorInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSString *str = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
            NSLog(@"===========================%@================================", str);
        }

        if ([[errorInfo allKeys] containsObject:AFNetworkingOperationFailingURLResponseErrorKey]) {
            NSLog(@"===============================%@===============================", errorInfo[AFNetworkingOperationFailingURLResponseErrorKey]);
        }
        if ([[errorInfo allKeys] containsObject:AFURLResponseSerializationErrorDomain]) {
            NSLog(@"===============================%@===============================", errorInfo[AFURLResponseSerializationErrorDomain]);
        }
    }

    if (completionHandler) {
        if (error) {
            completionHandler(nil, -1, error);
        } else {
            completionHandler(responseObject, responses.statusCode, nil);
            /*
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary * responseDic = [[NSMutableDictionary alloc]init];
                [responseDic addEntriesFromDictionary:responseObject];
                [responseDic setObject:@(responses.statusCode) forKey:@"StatusCode"];
                completionHandler(responseDic,nil);
            }
            else{
                completionHandler(responseObject,nil);
            }
            */
        }
    }
}

- (void)setRequsetIdentifierForRequest:(QIMHTTPRequest *)request taskIdentifier:(NSUInteger)taskIdentifier {
    NSString *identifier = [NSString stringWithFormat:@"%lu", taskIdentifier];
    [request setValue:identifier forKey:@"_identifier"];
}

- (void)setUrlHttpRequest:(NSMutableURLRequest *)urlReqeuest WithQImHttpRequest:(QIMHTTPRequest *)qImRequest {
    if (qImRequest.HTTPRequestHeaders.count > 0) {
        [qImRequest.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL *_Nonnull stop) {
            [urlReqeuest setValue:obj forHTTPHeaderField:key];
        }];
    }
    urlReqeuest.timeoutInterval = qImRequest.timeoutInterval;
}

- (QIMHTTPRequest *)getRequestWithIdentifier:(NSString *)identifier {
    if (identifier != nil) {
        NSArray *tasks = self.sessionManager.tasks;
        __block QIMHTTPRequest *request;
        [tasks enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            NSURLSessionTask *task = obj;
            if ([task.sessionBindRequest.identifier isEqualToString:identifier]) {
                request = task.sessionBindRequest;
                *stop = YES;
            }
        }];
        return request;
    }
    return nil;
}

- (QIMHTTPRequest *)cancelRequestIdentifier:(NSString *)identifier {
    if (identifier != nil) {
        NSArray *tasks = self.sessionManager.tasks;
        __block QIMHTTPRequest *request;
        [tasks enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            NSURLSessionTask *dataTask = obj;
            if ([dataTask.sessionBindRequest.identifier isEqualToString:identifier]) {
                request = dataTask.sessionBindRequest;
                [dataTask cancel];
                *stop = YES;
            }
        }];
        return request;
    }
    return nil;
}

- (void)setMaxCurrentOperationCount:(NSInteger)count {
    self.sessionManager.operationQueue.maxConcurrentOperationCount = count;
}

- (NSInteger)reacheablityStatus {
    return [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
}

@end
