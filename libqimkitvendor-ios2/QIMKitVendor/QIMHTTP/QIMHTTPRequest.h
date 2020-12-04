//
//  QIMHTTPRequest.h
//  QIMKitVendor
//
//  Created by 李露 on 2018/8/2.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QIMHTTPUploadComponent.h"
#import "QIMHTTPResponse.h"
#import "QIMHttpCommon.h"

@interface QIMHTTPRequest : NSObject

//request唯一标识
@property(nonatomic, copy, readonly) NSString *identifier;
/**
 请求的url,若为GET请求，直接在url后面拼接参数。
 */
@property(nonatomic, copy) NSURL *url;
@property(nonatomic) NSTimeInterval timeoutInterval;
/**
 http请求头
 */
@property(nonatomic, strong, nullable) NSMutableDictionary <NSString *, NSString *> *HTTPRequestHeaders;
/**
 http请求参数,GET请求会拼接到url后面，POST请求会拼接到body里面。若为GET请求，不要在此设置值。
 */
@property(nonatomic, strong, nullable) NSMutableDictionary *postParams;
/**
 上传文件需要的数据，不需要设置此项。
 */
@property(nonatomic, strong, nullable) NSMutableArray <QIMHTTPUploadComponent *> *uploadComponents;
/**
 defaut is NO,不对证书做校验
 */
@property(nonatomic) BOOL validatesSecureCertificate;
/*!
 @abstract Sets the HTTP request method of the receiver. POST or GET,default is GET.
 */
@property(nonatomic, assign) QIMHTTPMethod HTTPMethod;

@property(nonatomic, assign) QIMHTTPRequestType httpRequestType;

@property(nonatomic, strong, nullable) NSData *HTTPBody NS_DEPRECATED_IOS(2_0, 9_0, "DEPERCATED use postParams instead");

@property(nonatomic, assign) NSInteger retryCount;

@property(nonatomic, strong, nullable) NSMutableDictionary *userInfo;

@property(nonatomic, copy, readonly, nullable) QIMCompleteHandler completeHandler;

@property(nonatomic, copy, readonly, nullable) QIMFailureHandler failuerHandler;

@property(nonatomic, copy, readonly, nullable) QIMProgressHandler progressHandler;

@property(nonatomic, copy, readonly, nullable) QIMSuccessHandler successHandler;

@property(nonatomic, copy, readonly, nullable) QIMFinishHandler finishHandler;

@property(nonatomic, assign) QIMHttpRequestSerializer requestSerializer;

@property(nonatomic, assign) QIMHttpResponseSerializer responseSerializer;

@property(assign) BOOL useCookiePersistence;
/**
 default is YES,不做同步请求
 */
@property(nonatomic) BOOL shouldASynchronous;
/**
 下载文件存储的目标路径，要精确到文件名，在设定之前，需要在外部判定文件是否存在，是否需要删除。
 */
@property(nonatomic, copy, nullable) NSString *downloadDestinationPath;
/**
 下载文件存储的临时路径,如果下载时不设定此项，会有默认的临时路径。
 */
@property(nonatomic, copy, nullable) NSString *downloadTemporaryPath;

- (instancetype)initWithURL:(NSURL *)url;

+ (instancetype)requestWithURL:(NSURL *)url;

- (void)addFromDataWithDataKey:(NSString *_Nonnull)dataKey fileName:(NSString *)fileName filePath:(NSString *)filePath minetype:(NSString *)mimeType fileData:(NSData *_Nonnull)fileData;

- (void)cleanCallbackBlocks;

@end
