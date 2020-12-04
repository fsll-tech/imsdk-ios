//
//  UIImage+QIMMultiFormat.h
//  QIMSDWebImage
//
//  Created by Olivier Poitrey on 07/06/13.
//  Copyright (c) 2013 Dailymotion. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QIMMultiFormat)

+ (UIImage *)qimsd_imageWithData:(NSData *)data gifFlag:(BOOL)gifFlag;

@end
