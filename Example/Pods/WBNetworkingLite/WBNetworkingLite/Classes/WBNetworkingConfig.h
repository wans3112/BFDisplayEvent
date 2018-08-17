//
//  WBNetworkingConfig.h
//  WBNetworkingExample
//
//  Created by wans on 2017/9/14.
//  Copyright © 2017年 wans. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WBRequestConfig;
@class WBNetworkingConfig;
@class WBUploadData;

// 网络请求数据返回回调
typedef void (^WBHttpResponse)(id response, NSError *error);

// 调用时，自定义参数参入
typedef void (^WBHttpRequestConfig)(WBRequestConfig *request);
typedef void (^WBHttpConfig)(WBNetworkingConfig *config);



// 上传时参数传入
typedef void (^WBHttpUploadData)(WBUploadData *uploadData);
// 上传进度回调
typedef void (^WBHttpProgress)(NSProgress *progress);

static  NSString *kWBHttpMethodPost              = @"POST";
static  NSString *kWBHttpMethodGet               = @"GET";
static  NSString *kWBHttpMethodUpload            = @"UPLOAD";
static  NSString *kWBHttpMethodDownLoad          = @"DOWNLOAD";
static  NSString *kWBHttpMethodPut               = @"PUT";
static  NSString *kWBHttpMethodDelete            = @"DELETE";

/**
 无网络时默认错误提示
 */
#define kDefaultNetworkelessMsg                  @"网络不给力"

/**
 默认最大请求并发数
 */
#define kDefaultMaxConCurrentCount               5

/**
 默认超时时间
 */
#define kDefaultTimeoutInterval                  30

@interface WBNetworkingConfig : NSObject

/**
 根域名或ip地址
 */
@property (nonatomic,strong) NSString            *baseUrl;

/**
 超时时间
 */
@property (nonatomic,assign) NSTimeInterval      timeoutInterval;

/**
 默认的httpheader
 */
@property (nonatomic,strong) NSDictionary        *defaultHeaderFields;

/**
 默认的参数
 */
@property (nonatomic,strong) NSDictionary        *defaultParameters;

/**
 是否打印日志，Dubug默认打印，Release默认不打印
 */
@property (nonatomic,assign) BOOL                disEnableLog;

/**
 允许最大请求并发数，当设置为1时，则为同步发送请求。
 */
@property (nonatomic,assign) NSInteger           maxConcurrentCount;

@end


@interface WBRequestConfig : NSObject

/**
 请求路径
 */
@property (nonatomic,strong) NSString            *url;

/**
 请求参数 (字典或者json字符串)
 */
@property (nonatomic,strong) id                  parameters;

/**
 restful风格请求参数 ../{username}/{age}
 */
@property (nonatomic,strong) NSArray             *rf_parameters;

/**
 提交到服务的约定格式模式
 */
@property (nonatomic,strong) NSString            *contentType;

@end

@interface WBUploadData : NSObject

/**
 字段名
 */
@property (nonatomic,strong) NSString            *name;

/**
 上传数据内容
 */
@property (nonatomic,strong) NSData              *data;

/**
 数据的格式 eg image/jpg, image/png, application/pdf
 */
@property (nonatomic,strong) NSString            *contentType;

/**
 约定上传服务器的文件名
 */
@property (nonatomic,strong) NSString            *filename;

@end


