//
//  QIMHttpRequestConfig.h
//  QIMKitVendor
//
//  Created by qitmac000645 on 2019/6/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QIMHttpRequestConfig : NSObject
@property (nonatomic , strong) NSMutableDictionary <NSString * , NSString *> * commonHeaders;
@property (nonatomic , strong) NSMutableDictionary <NSString * , id> * commonParameters;
@property (nonatomic , strong) NSMutableDictionary * commonUserInfo;
@property (nonatomic , strong) NSURLSessionConfiguration * urlConfiguration;
@end

NS_ASSUME_NONNULL_END
