/*
 * This file is part of the QIMSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+QIMWebCache.h"
#import "objc/runtime.h"
#import "UIView+QIMWebCacheOperation.h"

static char imageURLKey;
static char TAG_ACTIVITY_INDICATOR;
static char TAG_ACTIVITY_STYLE;
static char TAG_ACTIVITY_SHOW;

@implementation UIImageView (WebCache)

- (void)qimsd_setImageWithURL:(NSURL *)url {
    [self qimsd_setImageWithURL:url placeholderImage:nil options:0 gifFlag:YES progress:nil completed:nil];
}

- (void)qimsd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self qimsd_setImageWithURL:url placeholderImage:placeholder options:0 gifFlag:YES progress:nil completed:nil];
}

- (void)qimsd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options {
    [self qimsd_setImageWithURL:url placeholderImage:placeholder options:options gifFlag:YES progress:nil completed:nil];
}

- (void)qimsd_setImageWithURL:(NSURL *)url completed:(QIMSDWebImageCompletionBlock)completedBlock {
    [self qimsd_setImageWithURL:url placeholderImage:nil options:0 gifFlag:YES progress:nil completed:completedBlock];
}

- (void)qimsd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(QIMSDWebImageCompletionBlock)completedBlock {
    [self qimsd_setImageWithURL:url placeholderImage:placeholder options:0 gifFlag:YES progress:nil completed:completedBlock];
}

- (void)qimsd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options completed:(QIMSDWebImageCompletionBlock)completedBlock {
    [self qimsd_setImageWithURL:url placeholderImage:placeholder options:options gifFlag:YES progress:nil completed:completedBlock];
}

- (void)qimsd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options gifFlag:(BOOL)flag progress:(QIMSDWebImageDownloaderProgressBlock)progressBlock completed:(QIMSDWebImageCompletionBlock)completedBlock {
    [self qimsd_cancelCurrentImageLoad];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if (!(options & QIMSDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            self.image = placeholder;
        });
    }
    
    if (url) {

        // check if activityView is enabled or not
        if ([self showActivityIndicatorView]) {
            [self addActivityIndicator];
        }

        __weak __typeof(self)wself = self;
        id <QIMSDWebImageOperation> operation = [QIMSDWebImageManager.sharedManager downloadImageWithURL:url options:options gifFlag:flag progress:progressBlock completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            [wself removeActivityIndicator];
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                if (image && (options & QIMSDWebImageAvoidAutoSetImage) && completedBlock)
                {
                    completedBlock(image, error, cacheType, url);
                    return;
                }
                else if (image) {
                    wself.image = image;
                    [wself setNeedsLayout];
                } else {
                    if ((options & QIMSDWebImageDelayPlaceholder)) {
                        wself.image = placeholder;
                        [wself setNeedsLayout];
                    }
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
        [self qimsd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
    } else {
        dispatch_main_async_safe(^{
            [self removeActivityIndicator];
            if (completedBlock) {
                NSError *error = [NSError errorWithDomain:QIMSDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
                completedBlock(nil, error, QIMSDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)qimsd_setImageWithPreviousCachedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options progress:(QIMSDWebImageDownloaderProgressBlock)progressBlock completed:(QIMSDWebImageCompletionBlock)completedBlock {
    NSString *key = [[QIMSDWebImageManager sharedManager] cacheKeyForURL:url];
    UIImage *lastPreviousCachedImage = [[QIMSDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    
    [self qimsd_setImageWithURL:url placeholderImage:lastPreviousCachedImage ?: placeholder options:options gifFlag:YES progress:progressBlock completed:completedBlock];
}

- (NSURL *)qimsd_imageURL {
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (void)qimsd_setAnimationImagesWithURLs:(NSArray *)arrayOfURLs {
    [self qimsd_cancelCurrentAnimationImagesLoad];
    __weak __typeof(self)wself = self;

    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];

    for (NSURL *logoImageURL in arrayOfURLs) {
        id <QIMSDWebImageOperation> operation = [QIMSDWebImageManager.sharedManager downloadImageWithURL:logoImageURL options:0 gifFlag:YES progress:nil completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                __strong UIImageView *sself = wself;
                [sself stopAnimating];
                if (sself && image) {
                    NSMutableArray *currentImages = [[sself animationImages] mutableCopy];
                    if (!currentImages) {
                        currentImages = [[NSMutableArray alloc] init];
                    }
                    [currentImages addObject:image];

                    sself.animationImages = currentImages;
                    [sself setNeedsLayout];
                }
                [sself startAnimating];
            });
        }];
        [operationsArray addObject:operation];
    }

    [self qimsd_setImageLoadOperation:[NSArray arrayWithArray:operationsArray] forKey:@"UIImageViewAnimationImages"];
}

- (void)qimsd_cancelCurrentImageLoad {
    [self qimsd_cancelImageLoadOperationWithKey:@"UIImageViewImageLoad"];
}

- (void)qimsd_cancelCurrentAnimationImagesLoad {
    [self qimsd_cancelImageLoadOperationWithKey:@"UIImageViewAnimationImages"];
}


#pragma mark -
- (UIActivityIndicatorView *)activityIndicator {
    return (UIActivityIndicatorView *)objc_getAssociatedObject(self, &TAG_ACTIVITY_INDICATOR);
}

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator {
    objc_setAssociatedObject(self, &TAG_ACTIVITY_INDICATOR, activityIndicator, OBJC_ASSOCIATION_RETAIN);
}

- (void)setShowActivityIndicatorView:(BOOL)show{
    objc_setAssociatedObject(self, &TAG_ACTIVITY_SHOW, [NSNumber numberWithBool:show], OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)showActivityIndicatorView{
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_SHOW) boolValue];
}

- (void)setIndicatorStyle:(UIActivityIndicatorViewStyle)style{
    objc_setAssociatedObject(self, &TAG_ACTIVITY_STYLE, [NSNumber numberWithInt:style], OBJC_ASSOCIATION_RETAIN);
}

- (int)getIndicatorStyle{
    return [objc_getAssociatedObject(self, &TAG_ACTIVITY_STYLE) intValue];
}

- (void)addActivityIndicator {
    if (!self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:[self getIndicatorStyle]];
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;

        dispatch_main_async_safe(^{
            [self addSubview:self.activityIndicator];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0.0]];
        });
    }

    dispatch_main_async_safe(^{
        [self.activityIndicator startAnimating];
    });

}

- (void)removeActivityIndicator {
    if (self.activityIndicator) {
        [self.activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
    }
}

@end


@implementation UIImageView (WebCacheDeprecated)

- (NSURL *)qimimageURL {
    return [self qimsd_imageURL];
}

- (void)qimsetImageWithURL:(NSURL *)url {
    [self qimsd_setImageWithURL:url placeholderImage:nil options:0 gifFlag:YES progress:nil completed:nil];
}

- (void)qimsetImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self qimsd_setImageWithURL:url placeholderImage:placeholder options:0 gifFlag:YES progress:nil completed:nil];
}

- (void)qimsetImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options {
    [self qimsd_setImageWithURL:url placeholderImage:placeholder options:options gifFlag:YES progress:nil completed:nil];
}

- (void)qimsetImageWithURL:(NSURL *)url completed:(QIMSDWebImageCompletedBlock)completedBlock {
    [self qimsd_setImageWithURL:url placeholderImage:nil options:0 gifFlag:YES progress:nil completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)qimsetImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(QIMSDWebImageCompletedBlock)completedBlock {
    [self qimsd_setImageWithURL:url placeholderImage:placeholder options:0 gifFlag:YES progress:nil completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)qimsetImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options completed:(QIMSDWebImageCompletedBlock)completedBlock {
    [self qimsd_setImageWithURL:url placeholderImage:placeholder options:options gifFlag:YES progress:nil completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)qimsetImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options progress:(QIMSDWebImageDownloaderProgressBlock)progressBlock completed:(QIMSDWebImageCompletedBlock)completedBlock {
    [self qimsd_setImageWithURL:url placeholderImage:placeholder options:options gifFlag:YES progress:progressBlock completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)qimsd_setImageWithPreviousCachedImageWithURL:(NSURL *)url andPlaceholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options progress:(QIMSDWebImageDownloaderProgressBlock)progressBlock completed:(QIMSDWebImageCompletionBlock)completedBlock {
    [self qimsd_setImageWithPreviousCachedImageWithURL:url placeholderImage:placeholder options:options progress:progressBlock completed:completedBlock];
}

- (void)qim_cancelCurrentArrayLoad {
    [self qimsd_cancelCurrentAnimationImagesLoad];
}

- (void)qim_cancelCurrentImageLoad {
    [self qimsd_cancelCurrentImageLoad];
}

- (void)qim_setAnimationImagesWithURLs:(NSArray *)arrayOfURLs {
    [self qimsd_setAnimationImagesWithURLs:arrayOfURLs];
}

@end
