/*
 * This file is part of the QIMSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIButton+QIMWebCache.h"
#import "objc/runtime.h"
#import "UIView+QIMWebCacheOperation.h"

static char imageURLStorageKey;

@implementation UIButton (QIMWebCache)

- (NSURL *)qimsd_currentImageURL {
    NSURL *url = self.imageURLStorage[@(self.state)];

    if (!url) {
        url = self.imageURLStorage[@(UIControlStateNormal)];
    }

    return url;
}

- (NSURL *)qimsd_imageURLForState:(UIControlState)state {
    return self.imageURLStorage[@(state)];
}

- (void)qimsd_setImageWithURL:(NSURL *)url forState:(UIControlState)state {
    [self qimsd_setImageWithURL:url forState:state placeholderImage:nil options:0 completed:nil];
}

- (void)qimsd_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder {
    [self qimsd_setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:nil];
}

- (void)qimsd_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options {
    [self qimsd_setImageWithURL:url forState:state placeholderImage:placeholder options:options completed:nil];
}

- (void)qimsd_setImageWithURL:(NSURL *)url forState:(UIControlState)state completed:(QIMSDWebImageCompletionBlock)completedBlock {
    [self qimsd_setImageWithURL:url forState:state placeholderImage:nil options:0 completed:completedBlock];
}

- (void)qimsd_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder completed:(QIMSDWebImageCompletionBlock)completedBlock {
    [self qimsd_setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)qimsd_setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options completed:(QIMSDWebImageCompletionBlock)completedBlock {

    [self setImage:placeholder forState:state];
    [self qimsd_cancelImageLoadForState:state];
    
    if (!url) {
        [self.imageURLStorage removeObjectForKey:@(state)];
        
        dispatch_main_async_safe(^{
            if (completedBlock) {
                NSError *error = [NSError errorWithDomain:QIMSDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
                completedBlock(nil, error, QIMSDImageCacheTypeNone, url);
            }
        });
        
        return;
    }
    
    self.imageURLStorage[@(state)] = url;

    __weak __typeof(self)wself = self;
    id <QIMSDWebImageOperation> operation = [QIMSDWebImageManager.sharedManager downloadImageWithURL:url options:options gifFlag:NO progress:nil completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (!wself) return;
        dispatch_main_sync_safe(^{
            __strong UIButton *sself = wself;
            if (!sself) return;
            if (image && (options & QIMSDWebImageAvoidAutoSetImage) && completedBlock)
            {
                completedBlock(image, error, cacheType, url);
                return;
            }
            else if (image) {
                [sself setImage:image forState:state];
            }
            if (completedBlock && finished) {
                completedBlock(image, error, cacheType, url);
            }
        });
    }];
    [self qimsd_setImageLoadOperation:operation forState:state];
}

- (void)qimsd_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state {
    [self qimsd_setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:nil];
}

- (void)qimsd_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder {
    [self qimsd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:nil];
}

- (void)qimsd_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options {
    [self qimsd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options completed:nil];
}

- (void)qimsd_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state completed:(QIMSDWebImageCompletionBlock)completedBlock {
    [self qimsd_setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:completedBlock];
}

- (void)qimsd_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder completed:(QIMSDWebImageCompletionBlock)completedBlock {
    [self qimsd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:completedBlock];
}

- (void)qimsd_setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options completed:(QIMSDWebImageCompletionBlock)completedBlock {
    [self qimsd_cancelBackgroundImageLoadForState:state];

    [self setBackgroundImage:placeholder forState:state];

    if (url) {
        __weak __typeof(self)wself = self;
        id <QIMSDWebImageOperation> operation = [QIMSDWebImageManager.sharedManager downloadImageWithURL:url options:options gifFlag:NO progress:nil completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                __strong UIButton *sself = wself;
                if (!sself) return;
                if (image && (options & QIMSDWebImageAvoidAutoSetImage) && completedBlock)
                {
                    completedBlock(image, error, cacheType, url);
                    return;
                }
                else if (image) {
                    [sself setBackgroundImage:image forState:state];
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType, url);
                }
            });
        }];
        [self qimsd_setBackgroundImageLoadOperation:operation forState:state];
    } else {
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:QIMSDWebImageErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, QIMSDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)qimsd_setImageLoadOperation:(id<QIMSDWebImageOperation>)operation forState:(UIControlState)state {
    [self qimsd_setImageLoadOperation:operation forKey:[NSString stringWithFormat:@"UIButtonImageOperation%@", @(state)]];
}

- (void)qimsd_cancelImageLoadForState:(UIControlState)state {
    [self qimsd_cancelImageLoadOperationWithKey:[NSString stringWithFormat:@"UIButtonImageOperation%@", @(state)]];
}

- (void)qimsd_setBackgroundImageLoadOperation:(id<QIMSDWebImageOperation>)operation forState:(UIControlState)state {
    [self qimsd_setImageLoadOperation:operation forKey:[NSString stringWithFormat:@"UIButtonBackgroundImageOperation%@", @(state)]];
}

- (void)qimsd_cancelBackgroundImageLoadForState:(UIControlState)state {
    [self qimsd_cancelImageLoadOperationWithKey:[NSString stringWithFormat:@"UIButtonBackgroundImageOperation%@", @(state)]];
}

- (NSMutableDictionary *)imageURLStorage {
    NSMutableDictionary *storage = objc_getAssociatedObject(self, &imageURLStorageKey);
    if (!storage)
    {
        storage = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &imageURLStorageKey, storage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return storage;
}

@end


@implementation UIButton (WebCacheDeprecated)

- (NSURL *)currentImageURL {
    return [self qimsd_currentImageURL];
}

- (NSURL *)imageURLForState:(UIControlState)state {
    return [self qimsd_imageURLForState:state];
}

- (void)setImageWithURL:(NSURL *)url forState:(UIControlState)state {
    [self qimsd_setImageWithURL:url forState:state placeholderImage:nil options:0 completed:nil];
}

- (void)setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder {
    [self qimsd_setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:nil];
}

- (void)setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options {
    [self qimsd_setImageWithURL:url forState:state placeholderImage:placeholder options:options completed:nil];
}

- (void)setImageWithURL:(NSURL *)url forState:(UIControlState)state completed:(QIMSDWebImageCompletedBlock)completedBlock {
    [self qimsd_setImageWithURL:url forState:state placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder completed:(QIMSDWebImageCompletedBlock)completedBlock {
    [self qimsd_setImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options completed:(QIMSDWebImageCompletedBlock)completedBlock {
    [self qimsd_setImageWithURL:url forState:state placeholderImage:placeholder options:options completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state {
    [self qimsd_setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:nil];
}

- (void)setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder {
    [self qimsd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:nil];
}

- (void)setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options {
    [self qimsd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options completed:nil];
}

- (void)setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state completed:(QIMSDWebImageCompletedBlock)completedBlock {
    [self qimsd_setBackgroundImageWithURL:url forState:state placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder completed:(QIMSDWebImageCompletedBlock)completedBlock {
    [self qimsd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:0 completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)setBackgroundImageWithURL:(NSURL *)url forState:(UIControlState)state placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options completed:(QIMSDWebImageCompletedBlock)completedBlock {
    [self qimsd_setBackgroundImageWithURL:url forState:state placeholderImage:placeholder options:options completed:^(UIImage *image, NSError *error, QIMSDImageCacheType cacheType, NSURL *imageURL) {
        if (completedBlock) {
            completedBlock(image, error, cacheType);
        }
    }];
}

- (void)cancelCurrentImageLoad {
    // in a backwards compatible manner, cancel for current state
    [self qimsd_cancelImageLoadForState:self.state];
}

- (void)cancelBackgroundImageLoadForState:(UIControlState)state {
    [self qimsd_cancelBackgroundImageLoadForState:state];
}

@end
