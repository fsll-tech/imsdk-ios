//
//  QIMHttpCommon.h
//  QIMKitVendor
//
//  Created by qitmac000645 on 2019/6/19.
//

#ifndef QIMHttpCommon_h
#define QIMHttpCommon_h

@class QIMHTTPResponse;
@class QIMHttpRequestConfig;
#define QIM_SAFE_BLOCK(BlockName, ...) ({ !BlockName ? nil : BlockName(__VA_ARGS__); })

typedef enum : NSUInteger {
    QIMHTTPMethodGET = 0,
    QIMHTTPMethodPOST,
} QIMHTTPMethod;

typedef NS_ENUM(NSInteger, QIMHTTPRequestType){
    QIMHTTPRequestTypeNormal   = 0,
    QIMHTTPRequestTypeUpload   = 1,
    QIMHTTPRequestTypeDownload = 2,
};

typedef NS_ENUM(NSInteger,QIMHttpRequestSerializer) {
    QIMHttpRequestSerializerHTTP = 1,
    QIMHttpRequestSerializerJSON = 2,
    QIMHttpRequestSerializerPLIST = 3,
};

typedef NS_ENUM(NSInteger,QIMHttpResponseSerializer) {
    QIMHttpResponseSerializerHTTP = 0,
    QIMHttpResponseSerializerJSON = 1,
    QIMHttpResponseSerializerPLIST = 2,
    QIMHttpResponseSerializerXML = 3,
};

typedef void(^QIMCompleteHandler)(QIMHTTPResponse * _Nullable response);


typedef void(^QIMSuccessHandler) (id _Nullable responseObjcet, NSInteger httpCode);
typedef void(^QIMFailureHandler)(NSError * error);
typedef void(^QIMProgressHandler)(NSProgress *progress);
typedef void(^QIMCancleBlock)(id _Nullable request);
typedef void(^QIMFinishHandler)(id _Nullable responseObject, NSError * _Nullable error);

#endif /* QIMHttpCommon_h */
