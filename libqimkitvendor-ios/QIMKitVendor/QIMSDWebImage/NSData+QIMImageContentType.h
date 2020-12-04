//
// Created by Fabrice Aneche on 06/01/14.
// Copyright (c) 2014 Dailymotion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (QIMImageContentType)

/**
 *  Compute the content type for an image data
 *
 *  @param data the input data
 *
 *  @return the content type as string (i.e. image/jpeg, image/gif)
 */
+ (NSString *)qimsd_contentTypeForImageData:(NSData *)data;

@end


@interface NSData (QIMImageContentTypeDeprecated)

+ (NSString *)qim_contentTypeForImageData:(NSData *)data __deprecated_msg("Use `qimsd_contentTypeForImageData:`");

@end
