//
//  QIMHTTPRequest.m
//  QIMKitVendor
//
//  Created by 李露 on 2018/8/2.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMHTTPRequest.h"
#import "NSObject+QIMRuntime.h"

@implementation QIMHTTPRequest

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _url = url;
        _timeoutInterval = 60;
        _HTTPMethod = QIMHTTPMethodGET;
    }
    return self;
}

+ (instancetype)requestWithURL:(NSURL *)url {
    return [[self alloc] initWithURL:url];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _httpRequestType = QIMHTTPRequestTypeNormal;
        _HTTPMethod = QIMHTTPMethodPOST;
        _timeoutInterval = 60.0;
        _retryCount = 3;
        _requestSerializer = QIMHttpRequestSerializerJSON;
        _responseSerializer = QIMHttpResponseSerializerJSON;
    }
    return self;
}

- (NSMutableArray<QIMHTTPUploadComponent *> *)uploadComponents {
    if (!_uploadComponents) {
        _uploadComponents = [NSMutableArray array];
    }
    return _uploadComponents;
}

- (void)addFromDataWithDataKey:(NSString *)dataKey fileName:(NSString *)fileName filePath:(NSString *)filePath minetype:(NSString *)mimeType fileData:(NSData *)fileData {
    [self.uploadComponents addObject:[QIMHTTPUploadComponent addFromDataWithDataKey:dataKey fileName:fileName filePath:filePath minetype:mimeType fileData:fileData fileUrl:nil]];
}

- (void)cleanCallbackBlocks {
    _completeHandler = nil;
    _failuerHandler = nil;
    _progressHandler = nil;
    _finishHandler = nil;
}

- (NSString *)description {
    NSMutableString *str = [NSMutableString stringWithString:[self qim_properties_aps]];
    return str;
}

@end
