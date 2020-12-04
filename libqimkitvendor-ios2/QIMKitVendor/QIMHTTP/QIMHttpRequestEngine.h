//
//  QIMHttpRequestEngine.h
//  QIMKitVendor
//
//  Created by qitmac000645 on 2019/6/19.
//

#import <Foundation/Foundation.h>
#import "QIMHttpCommon.h"
@class QIMHTTPRequest;
NS_ASSUME_NONNULL_BEGIN

typedef void(^QIMHttpCompletionHandler)(id _Nullable responseObject, NSInteger HTTPStatusCode, NSError * _Nullable error);

@interface QIMHttpRequestEngine : NSObject

+(instancetype)shareEngine;

- (void)sendRequest:(QIMHTTPRequest *)request completionHandle:(QIMHttpCompletionHandler)completionHandler;

- (QIMHTTPRequest *)cancelRequestIdentifier:(NSString *)identifier;

- (QIMHTTPRequest *)getRequestWithIdentifier:(NSString *)identifier;

- (void)setMaxCurrentOperationCount:(NSInteger)count;

- (NSInteger)reacheablityStatus;

@end

NS_ASSUME_NONNULL_END
