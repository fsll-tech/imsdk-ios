//
//  QIMSchemaManager.h
//  QIMCommon
//
//  Created by 李露 on 2018/9/11.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QIMSchemaManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)isLocalSchemaWithUrl:(NSString *)url;

- (void)postSchemaNotificationWithUrl:(NSURL *)url;

@end
