/*
 * This file is part of the QIMSDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "QIMSDWebImageCompat.h"
#import "QIMSDWebImageManager.h"

/**
 * Integrates QIMSDWebImage async downloading and caching of remote images with UIImageView.
 *
 * Usage with a UITableViewCell sub-class:
 *
 * @code

#import <QIMSDWebImage/UIImageView+WebCache.h>

...

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
 
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
 
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier]
                 autorelease];
    }
 
    // Here we use the provided qimsd_setImageWithURL: method to load the web image
    // Ensure you use a placeholder image otherwise cells will be initialized with no image
    [cell.imageView qimsd_setImageWithURL:[NSURL URLWithString:@"http://example.com/image.jpg"]
                      placeholderImage:[UIImage imageNamed:@"placeholder"]];
 
    cell.textLabel.text = @"My Text";
    return cell;
}

 * @endcode
 */
@interface UIImageView (WebCache)

/**
 * Get the current image URL.
 *
 * Note that because of the limitations of categories this property can get out of sync
 * if you use qimsd_setImage: directly.
 */
- (NSURL *)qimsd_imageURL;

/**
 * Set the imageView `image` with an `url`.
 *
 * The download is asynchronous and cached.
 *
 * @param url The url for the image.
 */
- (void)qimsd_setImageWithURL:(NSURL *)url;

/**
 * Set the imageView `image` with an `url` and a placeholder.
 *
 * The download is asynchronous and cached.
 *
 * @param url         The url for the image.
 * @param placeholder The image to be set initially, until the image request finishes.
 * @see qimsd_setImageWithURL:placeholderImage:options:
 */
- (void)qimsd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

/**
 * Set the imageView `image` with an `url`, placeholder and custom options.
 *
 * The download is asynchronous and cached.
 *
 * @param url         The url for the image.
 * @param placeholder The image to be set initially, until the image request finishes.
 * @param options     The options to use when downloading the image. @see QIMSDWebImageOptions for the possible values.
 */
- (void)qimsd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options;

/**
 * Set the imageView `image` with an `url`.
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
- (void)qimsd_setImageWithURL:(NSURL *)url completed:(QIMSDWebImageCompletionBlock)completedBlock;

/**
 * Set the imageView `image` with an `url`, placeholder.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 */
- (void)qimsd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(QIMSDWebImageCompletionBlock)completedBlock;

/**
 * Set the imageView `image` with an `url`, placeholder and custom options.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param options        The options to use when downloading the image. @see QIMSDWebImageOptions for the possible values.
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 */
- (void)qimsd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options completed:(QIMSDWebImageCompletionBlock)completedBlock;

/**
 * Set the imageView `image` with an `url`, placeholder and custom options.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param options        The options to use when downloading the image. @see QIMSDWebImageOptions for the possible values.
 * @param progressBlock  A block called while image is downloading
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 */
- (void)qimsd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options gifFlag:(BOOL)flag progress:(QIMSDWebImageDownloaderProgressBlock)progressBlock completed:(QIMSDWebImageCompletionBlock)completedBlock;
//- (void)qimsd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options progress:(QIMSDWebImageDownloaderProgressBlock)progressBlock completed:(QIMSDWebImageCompletionBlock)completedBlock;

/**
 * Set the imageView `image` with an `url` and optionally a placeholder image.
 *
 * The download is asynchronous and cached.
 *
 * @param url            The url for the image.
 * @param placeholder    The image to be set initially, until the image request finishes.
 * @param options        The options to use when downloading the image. @see QIMSDWebImageOptions for the possible values.
 * @param progressBlock  A block called while image is downloading
 * @param completedBlock A block called when operation has been completed. This block has no return value
 *                       and takes the requested UIImage as first parameter. In case of error the image parameter
 *                       is nil and the second parameter may contain an NSError. The third parameter is a Boolean
 *                       indicating if the image was retrieved from the local cache or from the network.
 *                       The fourth parameter is the original image url.
 */
- (void)qimsd_setImageWithPreviousCachedImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options progress:(QIMSDWebImageDownloaderProgressBlock)progressBlock completed:(QIMSDWebImageCompletionBlock)completedBlock;

/**
 * Download an array of images and starts them in an animation loop
 *
 * @param arrayOfURLs An array of NSURL
 */
- (void)qimsd_setAnimationImagesWithURLs:(NSArray *)arrayOfURLs;

/**
 * Cancel the current download
 */
- (void)qimsd_cancelCurrentImageLoad;

- (void)qimsd_cancelCurrentAnimationImagesLoad;

/**
 *  Show activity UIActivityIndicatorView
 */
- (void)setShowActivityIndicatorView:(BOOL)show;

/**
 *  set desired UIActivityIndicatorViewStyle
 *
 *  @param style The style of the UIActivityIndicatorView
 */
- (void)setIndicatorStyle:(UIActivityIndicatorViewStyle)style;

@end


@interface UIImageView (WebCacheDeprecated)

- (NSURL *)imageURL __deprecated_msg("Use `qimsd_imageURL`");

- (void)qim_setImageWithURL:(NSURL *)url __deprecated_msg("Method deprecated. Use `qimsd_setImageWithURL:`");
- (void)qim_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder __deprecated_msg("Method deprecated. Use `qimsd_setImageWithURL:placeholderImage:`");
- (void)qim_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options __deprecated_msg("Method deprecated. Use `qimsd_setImageWithURL:placeholderImage:options`");

- (void)qim_setImageWithURL:(NSURL *)url completed:(QIMSDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `qimsd_setImageWithURL:completed:`");
- (void)qim_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(QIMSDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `qimsd_setImageWithURL:placeholderImage:completed:`");
- (void)qim_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options completed:(QIMSDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `qimsd_setImageWithURL:placeholderImage:options:completed:`");
- (void)qim_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options progress:(QIMSDWebImageDownloaderProgressBlock)progressBlock completed:(QIMSDWebImageCompletedBlock)completedBlock __deprecated_msg("Method deprecated. Use `qimsd_setImageWithURL:placeholderImage:options:progress:completed:`");

- (void)qim_qimsd_setImageWithPreviousCachedImageWithURL:(NSURL *)url andPlaceholderImage:(UIImage *)placeholder options:(QIMSDWebImageOptions)options progress:(QIMSDWebImageDownloaderProgressBlock)progressBlock completed:(QIMSDWebImageCompletionBlock)completedBlock __deprecated_msg("Method deprecated. Use `qimsd_setImageWithPreviousCachedImageWithURL:placeholderImage:options:progress:completed:`");

- (void)qim_setAnimationImagesWithURLs:(NSArray *)arrayOfURLs __deprecated_msg("Use `qimsd_setAnimationImagesWithURLs:`");

- (void)qim_cancelCurrentArrayLoad __deprecated_msg("Use `qimsd_cancelCurrentAnimationImagesLoad`");

- (void)qim_cancelCurrentImageLoad __deprecated_msg("Use `qimsd_cancelCurrentImageLoad`");

@end
