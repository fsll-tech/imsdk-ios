//
//  UIImage+QIMUtility.h
//  QunariPhone
//
//  Created by 姜琢 on 13-6-8.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QIMUtility)
- (UIImage *)qim_sdImage;
+ (UIImage *)qim_imageFromColor:(UIColor *)color;
+ (UIImage *)qim_imageWithColor:(UIColor *)color size:(CGSize)size;
- (UIImage *)qim_getSubImage:(CGRect)rect;
- (UIImage *)qim_scaleToSize:(CGSize)size;
+ (UIImage *)qim_TransformtoSize:(CGSize)size image:(UIImage *)image;

- (UIImage *)qim_imageWithMaxLength:(CGFloat)sideLenght;

+ (CGSize)qim_getImageSizeWithURL:(id)imageURL;

+ (UIImage *)qim_screenShotInWindow NS_EXTENSION_UNAVAILABLE_IOS("QIM_EXTENSION");

+ (NSString *)qim_contentTypeForImageData:(NSData *)data;

+ (UIImage *)qim_grayscaleImage: (UIImage *) image;

+ (BOOL)qim_imageHasAlpha: (UIImage *) image;

+ (NSString *)qim_image2DataURL: (UIImage *) image;

+ (UIImage *)qim_imageNamed:(NSString *)name;

- (UIImage*)qim_imageByScalingAndCroppingForSize:(CGSize)targetSize;

+ (UIImage *)qim_imageWithColor:(UIColor *)color
                           size:(CGSize)size
                           text:(NSString *)text
                 textAttributes:(NSDictionary *)textAttributes
                       circular:(BOOL)isCircular;

@end
