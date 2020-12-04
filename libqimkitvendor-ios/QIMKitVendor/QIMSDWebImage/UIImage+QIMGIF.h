//
//  UIImage+QIMGIF.h
//  LBGIFImage
//
//  Created by Laurin Brandner on 06.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QIMGIF)

+ (UIImage *)qimsd_animatedGIFNamed:(NSString *)name;

+ (UIImage *)qimsd_animatedGIFWithData:(NSData *)data;

+ (UIImage *)qimsd_animatedGIFWithData:(NSData *)data gifFlag:(BOOL)gifFlag;

- (UIImage *)qimsd_animatedImageByScalingAndCroppingToSize:(CGSize)size;

@end
