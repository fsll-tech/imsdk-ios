/*
 * This file is part of the QIMSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+QIMHighlightedWebCache.h"
#import "UIView+QIMWebCacheOperation.h"

#define UIImageViewHighlightedWebCacheOperationKey @"highlightedImage"

@implementation UIImageView (HighlightedWebCache)

- (void)qimsd_setHighlightedImageWithURL:(NSURL *)url {
    [self qimsd_setHighlightedImageWithURL:url options:0 progress:nil completed:nil];
}

- (void)qimsd_setHighlightedImageWithURL:(NSURL *)url options:(QIMSDWebImageOptions)options {
    [self qimsd_setHighlightedImageWithURL:url options:options progress:nil completed:nil];
}

- (void)qimsd_setHighlightedImageWithURL:(NSURL *)url completed:(QIMSDWebImageCompletionBlock)completedBlock {
    [self qimsd_setHighlightedImageWithURL:url options:0 progress:nil completed:completedBlock];
}

- (void)qimsd_setHighlightedImageWithURL:(NSURL *)url options:(QIMSDWebImageOptions)options completed:(QIMSDWebImageCompletionBlock)completedBlock {
    [self qimsd_setHighlightedImageWithURL:url options:options progress:nil completed:completedBlock];
}

- (void)qimsd_setHighlightedImageWithURL:(NSURL *)url options:(QIMSDWebImageOptions)options progress:(QIMSDWebImageDownloaderProgressBlock)progressBlock completed:(QIMSDWebImageCompletionBlock)completedBlock {
    [self qimsd_cancelCurrentHighlightedImageLoad];

    if (url) {
        __weak __typeof(self)wself = self;
        id<QIMSDWebImageOperation> operation = [QIMSDWebImageManager.sharedManager downloadImageWithURL:url options:options gifFlag:NO progress:progressBlock completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe (^
                                     {
                                         if (!wself) return;
                                         if (image && (options & QIMSDWebImageAvoidAutoSetImage) && completedBlock)
                                         {
                                             completedBlock(image, error, cacheType, url);
                                             return;
                                         }
                                         else if (image) {
                                             wself.highlightedImage = image;
                                             [wself setNeedsLayout];
                                         }
                                         if (completedBlock && finished) {
                                             completedBlock(image, error, cacheType, url);
                                         }
                                     });
        }];
        [self qimsd_setImageLoadOperation:operation forKey:UIImageViewHighlightedWebCacheOperationKey];
    } else {
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:QIMSDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, QIMSDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)qimsd_cancelCurrentHighlightedImageLoad {
    [self qimsd_cancelImageLoadOperationWithKey:UIImageViewHighlightedWebCacheOperationKey];
}

@end


@implementation UIImageView (HighlightedWebCacheDeprecated)

- (void)setHighlightedImageWithURL:(NSURL *)url {
    [self qimsd_setHighlightedImageWithURL:url options:0 progress:nil completed:nil];
}

- (void)setHighlightedImageWithURL:(NSURL *)url options:(QIMSDWebImageOptions)options {
    [self qimsd_setHighlightedImageWithURL:url options:options progress:nil completed:nil];
}

- (void)setHighlightedImageWithURL:(NSURL *)url completed:(QIMSDWebImageCompletedBlock)completedBlock {
    [self qimsd_setHighlightedImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setHighlightedImageWithURL:(NSURL *)url options:(QIMSDWebImageOptions)options completed:(QIMSDWebImageCompletedBlock)completedBlock {
    [self qimsd_setHighlightedImageWithURL:url options:options progress:nil completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setHighlightedImageWithURL:(NSURL *)url options:(QIMSDWebImageOptions)options progress:(QIMSDWebImageDownloaderProgressBlock)progressBlock completed:(QIMSDWebImageCompletedBlock)completedBlock {
    [self qimsd_setHighlightedImageWithURL:url options:0 progress:progressBlock completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)cancelCurrentHighlightedImageLoad {
    [self qimsd_cancelCurrentHighlightedImageLoad];
}

@end
