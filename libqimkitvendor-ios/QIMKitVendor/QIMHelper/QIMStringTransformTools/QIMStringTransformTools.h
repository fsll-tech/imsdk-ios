//
//  QIMStringTransformTools.h
//  QunarUGC
//
//  Created by ping.xue on 13-11-11.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMStringTransformTools : NSObject

+ (NSString *)qim_CapacityTransformStrWithSize:(long long)size;


+ (NSString *)qim_CapacityTransformStrWithSize:(long long)size WithStrLenght:(NSUInteger)length;

@end
