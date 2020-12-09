//
//  QIMHttpRequestManager.m
//  QIMKitVendor
//
//  Created by qitmac000645 on 2019/6/19.
//

#import "QIMHttpRequestManager.h"
#import "QIMHttpRequestEngine.h"
#import "QIMHttpRequestConfig.h"
#import "QIMHTTPRequest.h"

@interface QIMHttpRequestManager ()
@property(nonatomic, strong) QIMHttpRequestEngine *engine;
@property(nonatomic, strong) QIMHttpRequestConfig *httpRequestConfig;
@end

@implementation QIMHttpRequestManager

+ (instancetype)sharedManger {
    static QIMHttpRequestManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _engine = [QIMHttpRequestEngine shareEngine];
    }
    return self;
}

- (void)setQIMHttpRequestConfig:(void (^)(QIMHttpRequestConfig *_Nonnull reuestConfig))config {
    self.httpRequestConfig = [[QIMHttpRequestConfig alloc] init];
    config(self.httpRequestConfig);
}

- (void)sendRequest:(void (^)(QIMHTTPRequest *qtRequest))requestHandler
       successBlock:(QIMSuccessHandler)succsessHandler
       failureBlock:(QIMFailureHandler)failureHandler {
    [self qimSendRequest:requestHandler progressBLock:nil successBlock:succsessHandler failureBlock:failureHandler finishBlock:nil];
}


- (void)sendRequest:(void (^)(QIMHTTPRequest *qtRequest))requestHandler
       successBlock:(QIMSuccessHandler)succsessHandler
       failureBlock:(nonnull QIMFailureHandler)failureHandler
        finishBlock:(nonnull QIMFinishHandler)finishBlock {
    [self qimSendRequest:requestHandler progressBLock:nil successBlock:succsessHandler failureBlock:failureHandler finishBlock:finishBlock];
}

- (void)sendRequest:(void (^)(QIMHTTPRequest *qtRequest))requestHandler
      progressBLock:(QIMProgressHandler)progressHandlder
       successBlock:(QIMSuccessHandler)succsessHandler
       failureBlock:(QIMFailureHandler)failureHandler
        finishBlock:(QIMFinishHandler)finishHandler {
    [self qimSendRequest:requestHandler progressBLock:progressHandlder successBlock:succsessHandler failureBlock:failureHandler finishBlock:finishHandler];
}


- (void)qimSendRequest:(void (^)(QIMHTTPRequest *qtRequest))request
         progressBLock:(QIMProgressHandler)progressHandlder
          successBlock:(QIMSuccessHandler)succsessHandler
          failureBlock:(QIMFailureHandler)failureHandler
           finishBlock:(QIMFinishHandler)finishHandler {
    QIMHTTPRequest *qimRequest = [[QIMHTTPRequest alloc] init];
    request(qimRequest);
    [self processRequest:qimRequest successBlock:succsessHandler progressBLock:progressHandlder failureBlock:failureHandler finishBlock:finishHandler];
    [self sentRequest:qimRequest];
}


- (void)processRequest:(QIMHTTPRequest *)request
          successBlock:(QIMSuccessHandler)succsessHandler
         progressBLock:(QIMProgressHandler)progressHandlder
          failureBlock:(QIMFailureHandler)failureHandler
           finishBlock:(QIMFinishHandler)finishHandle {
    if (succsessHandler) {
        [request setValue:succsessHandler forKey:@"_successHandler"];
    }
    if (failureHandler) {
        [request setValue:failureHandler forKey:@"_failuerHandler"];
    }
    if (progressHandlder) {
        [request setValue:progressHandlder forKey:@"_progressHandler"];
    }
    if (finishHandle) {
        [request setValue:finishHandle forKey:@"_finishHandler"];
    }

    if (!request.userInfo && self.httpRequestConfig.commonUserInfo.count > 0) {
        request.userInfo = self.httpRequestConfig.commonUserInfo;
    } else if (request.userInfo && self.httpRequestConfig.commonUserInfo) {
        [request.userInfo addEntriesFromDictionary:self.httpRequestConfig.commonUserInfo];
    } else {

    }

    if (request.HTTPRequestHeaders && self.httpRequestConfig.commonHeaders.count > 0) {
        [request.HTTPRequestHeaders addEntriesFromDictionary:self.httpRequestConfig.commonHeaders];
    }

    if (request.postParams && self.httpRequestConfig.commonParameters.count > 0) {
        [request.postParams addEntriesFromDictionary:self.httpRequestConfig.commonParameters];
    }
}


- (void)sentRequest:(QIMHTTPRequest *)request {
    [self.engine sendRequest:request completionHandle:^(id _Nullable responseObject, NSInteger HTTPStatusCode, NSError *_Nullable error) {
        if (error == nil) {
            [self requestSuccessWithResponse:responseObject withHTTPCode:HTTPStatusCode forRequest:request];
        } else {
            [self reuqestFailedWithError:error forRequset:request];
        }
    }];
}


- (void)requestSuccessWithResponse:(id)responseObjcet withHTTPCode:(NSInteger)httpCode forRequest:(QIMHTTPRequest *)request {
    request.successHandler(responseObjcet, httpCode);
    [request cleanCallbackBlocks];
}

- (void)reuqestFailedWithError:(NSError *)error forRequset:(QIMHTTPRequest *)requset {
    requset.failuerHandler(error);
    [requset cleanCallbackBlocks];
}

- (void)cancelRequest:(NSString *)identifier {
    [self.engine cancelRequestIdentifier:identifier];
}

@end
