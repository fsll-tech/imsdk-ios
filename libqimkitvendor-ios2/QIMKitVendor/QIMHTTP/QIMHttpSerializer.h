//
//  QIMHttpSerializer.h
//  QIMKitVendor
//
//  Created by qitmac000645 on 2019/6/25.
//

#import <Foundation/Foundation.h>
#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"
#import "QIMHttpCommon.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMHttpSerializer : NSObject
- (id <AFURLRequestSerialization>)requestSeialization:(QIMHttpRequestSerializer)requestSerializer;

- (id <AFURLResponseSerialization>)responseSeialization:(QIMHttpResponseSerializer)responseSerializer;
@end

NS_ASSUME_NONNULL_END
