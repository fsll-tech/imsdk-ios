//
//  QIMHttpRequestManager.h
//  QIMKitVendor
//
//  Created by qitmac000645 on 2019/6/19.
//

#import <Foundation/Foundation.h>
#import "QIMHttpCommon.h"

@class QIMHttpRequestConfig;
@class QIMHTTPRequest;
NS_ASSUME_NONNULL_BEGIN

@interface QIMHttpRequestManager : NSObject

+ (instancetype)sharedManger;

- (void)setQIMHttpRequestConfig:(void (^)(QIMHttpRequestConfig *requestConfig))config;

- (void)sendRequest:(void (^)(QIMHTTPRequest *qtRequest))rqeuestHandler
       successBlock:(QIMSuccessHandler)succsessHandler
       failureBlock:(QIMFailureHandler)failureHandler;

- (void)sendRequest:(void (^)(QIMHTTPRequest *qtRequest))requestHandler
       successBlock:(QIMSuccessHandler)succsessHandler
       failureBlock:(QIMFailureHandler)failureHandler
        finishBlock:(QIMFinishHandler)finishBlock;

- (void)sendRequest:(void (^)(QIMHTTPRequest *qtRequest))requestHandler
      progressBLock:(QIMProgressHandler)progressHandlder
       successBlock:(QIMSuccessHandler)succsessHandler
       failureBlock:(QIMFailureHandler)failureHandler
        finishBlock:(QIMFinishHandler)finishHandler;

- (void)cancelRequest:(NSString *)identifier;

- (void)getRequest:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
