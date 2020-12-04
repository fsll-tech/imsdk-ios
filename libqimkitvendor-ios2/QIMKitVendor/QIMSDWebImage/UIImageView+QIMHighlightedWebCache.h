/*
 * This file is part of the QIMSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <UIKit/UIKit.h>
#import "QIMSDWebImageCompat.h"
#import "QIMSDWebImageManager.h"

/**
 * Integrates QIMSDWebImage async downloading and caching of remote images with UIImageView for highlighted state.
 */
@interface UIImageView (HighlightedWebCache)

/**
 * Set the imageView `highlightedImage` with an `url`.
 *
 * The download is asynchronous and cached.
 *
 * @param url The url for the image.
 */
- (void)qimsd_setHighlightedImageWithURL:(NSURL *)url;

/**
 * Set the imageView `highlightedImage` with an `url` and custom options.
 *
 * The download is asynchronous and cached.
 *
 * @param url     The url for the image.
 * @param options The options to use when downloading the image. @see QIMSDWebImageOptions for the possible values.
 */
- (void)qimsd_setHighlightedImageWithURL:(NSURL *)url options:(QIMSDWebImageOptions)options;

/**
 * Set the imageView `highlightedImage` with an `url`.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 */
- (void)qimsd_setHighlightedImageWithURL:(NSURL *)url completed:(QIMSDWebImageCompletionBlock)completedBlock;

/**
 * Set the imageView `highlightedImage` with an `url` and custom options.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param options        The options to use when downloading the image. @see QIMSDWebImageOptions for the possible values.
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 */
- (void)qimsd_setHighlightedImageWithURL:(NSURL *)url options:(QIMSDWebImageOptions)options completed:(QIMSDWebImageCompletionBlock)completedBlock;

/**
 * Set the imageView `highlightedImage` with an `url` and custom options.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param options        The options to use when downloading the image. @see QIMSDWebImageOptions for the possible values.
 * @param progressBlock  A block called while image is downloading
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 */
- (void)qimsd_setHighlightedImageWithURL:(NSURL *)url options:(QIMSDWebImageOptions)options progress:(QIMSDWebImageDownloaderProgressBlock)progressBlock completed:(QIMSDWebImageCompletionBlock)completedBlock;

/**
 * Cancel the current download
 */
- (void)qimsd_cancelCurrentHighlightedImageLoad;

@end


@interface UIImageView (HighlightedWebCacheDeprecated)

- (void)setHighlightedImageWithURL:(NSURL *)url __deprecated_msg("Method deprecated. Use `qimsd_setHighlightedImageWithURL:`");
- (void)setHighlightedImageWithURL:(NSURL *)url options:(QIMSDWebImageOptions)options __deprecated_msg("Method deprecated. Use `qimsd_setHighlightedImageWithURL:options:`");
- (void)setHighlightedImageWithURL:(NSURL *)url completed:(QIMSDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `qimsd_setHighlightedImageWithURL:completed:`");
- (void)setHighlightedImageWithURL:(NSURL *)url options:(QIMSDWebImageOptions)options completed:(QIMSDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `qimsd_setHighlightedImageWithURL:options:completed:`");
- (void)setHighlightedImageWithURL:(NSURL *)url options:(QIMSDWebImageOptions)options progress:(QIMSDWebImageDownloaderProgressBlock)progressBlock completed:(QIMSDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `qimsd_setHighlightedImageWithURL:options:progress:completed:`");

- (void)cancelCurrentHighlightedImageLoad __deprecated_msg("Use `qimsd_cancelCurrentHighlightedImageLoad`");

@end
