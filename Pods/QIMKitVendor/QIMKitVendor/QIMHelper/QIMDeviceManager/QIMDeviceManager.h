//
//  QIMDeviceManager.h
//  QIMUIKit
//
//  Created by 李露 on 10/10/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QIMDeviceManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)isIphoneXSeries NS_EXTENSION_UNAVAILABLE_IOS("QIM_EXTENSION");

- (CGFloat)getHOME_INDICATOR_HEIGHT NS_EXTENSION_UNAVAILABLE_IOS("QIM_EXTENSION");

- (CGFloat)getTAB_BAR_HEIGHT NS_EXTENSION_UNAVAILABLE_IOS("QIM_EXTENSION");

- (CGFloat)getNAVIGATION_BAR_HEIGHT NS_EXTENSION_UNAVAILABLE_IOS("QIM_EXTENSION");

- (CGFloat)getSTATUS_BAR_HEIGHT NS_EXTENSION_UNAVAILABLE_IOS("QIM_EXTENSION");

@end

NS_ASSUME_NONNULL_END
