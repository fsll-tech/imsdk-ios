//
//  QIMHTTPUploadComponent.h
//  QIMKitVendor
//
//  Created by 李露 on 2018/8/2.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QIMHTTPUploadComponent : NSObject

/**
 dataKey: 每一个dataKey对应于一个filePath或者data数据,在同一次传输中要保证dataKey唯一，不能为空；
 fileName: 指定上传文件的名字，可以为空，为空时取原文件名字；
 filePath: 上传的文件路径
 data: 上传的data数据
 */

@property (nonatomic, copy, nonnull) NSString *dataKey;
@property (nonatomic, copy, nullable) NSString * filePath;
@property (nonatomic, copy, nullable) NSString * fileName;
@property (nonatomic, copy, nullable) NSString * mimeType;
//@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong, nullable) NSData * fileData;
@property (nonatomic, strong, nullable) NSURL * fileUrl;
@property (nonatomic, strong) NSDictionary *bodyDic;

/**
 Appends the HTTP header `Content-Disposition: file; filename=#{filename}; name=#{name}"` and `Content-Type: #{mimeType}`, followed by the data from the input stream and the multipart form boundary.
 @param dataKey 上传的data所需要的key，不能为空
 @param filePath 上传的文件路径，不能为空
 The fileName and MIME type for this data in the form will be automatically generated, using the last path component of the `filePath` and system associated MIME type for the `filePath` extension, respectively.
 @return A newly-created and autoreleased ZHHTTPUploadComponent instance.
 */
- (instancetype)initWithDataKey:(NSString *)dataKey filePath:(NSString *)filePath;

+ (QIMHTTPUploadComponent *)addFromDataWithDataKey:(NSString *  _Nonnull)dataKey fileName:(NSString *_Nullable)fileName filePath:(NSString * _Nullable)filePath minetype:(NSString * _Nullable)mimeType fileData:(NSData *  _Nonnull)fileData fileUrl:(NSURL * _Nonnull)fileUrl;


- (instancetype)initWithDataKey:(NSString *)dataKey fileData:(NSData *)fileData;

@end
