//
//  NSURLSessionTask+QIMHttpRequest.h
//  QIMKitVendor
//
//  Created by qitmac000645 on 2019/6/20.
//

#import <Foundation/Foundation.h>
#import "QIMHTTPRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSessionTask (QIMHttpRequest)
@property(nonatomic, strong) QIMHTTPRequest *sessionBindRequest;
@end

NS_ASSUME_NONNULL_END
