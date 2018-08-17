//
//  WBNetworking.h
//  WBExampleProject
//
//  Created by wans on 2017/5/4.
//  Copyright © 2017年 wans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBNetworkingConfig.h"

@interface WBNetworking : NSObject

+ (void)setupConfig:(WBHttpConfig)config;//!< 配置网络库，根域名，默认Header,超时时间等属性
+ (void)updateHttpConfig:(WBHttpConfig)config;//!< 更新网络库配置，只会更新，不会替换，如删除，将对应的value置空。
+ (WBNetworkingConfig *)config;//!< 获取网络库配置


/**
 get请求
 
 @param request 请求参数
 @param response 完成回调
 
 */
+ (void)GET:(WBHttpRequestConfig)request response:(WBHttpResponse)response;


/**
 post请求

 @param request 请求参数
 @param response 完成回调
 
 */
+ (void)POST:(WBHttpRequestConfig)request response:(WBHttpResponse)response;


/**
 put请求
 
 @param request 请求参数
 @param response 完成回调
 
 */
+ (void)PUT:(WBHttpRequestConfig)request response:(WBHttpResponse)response;

/**
 delete请求
 
 @param request 请求参数
 @param response 完成回调
 
 */
+ (void)DELETE:(WBHttpRequestConfig)request response:(WBHttpResponse)response;

/**
 下载请求

 @param request 请求参数
 @param progress 进度百分比
 @param response 完成回调
 
 */
+ (void)DOWNLOAD:(WBHttpRequestConfig)request progress:(WBHttpProgress)progress response:(WBHttpResponse)response;


/**
 上传请求

 @param request 请求参数
 @param uploadData 上传数据
 @param progress 进度百分比
 @param response 完成回调
 
 */
+ (void)UPLOAD:(WBHttpRequestConfig)request uploadData:(WBHttpUploadData)uploadData  progress:(WBHttpProgress)progress response:(WBHttpResponse)response;

/**
 取消请求

 @param url 请求地址
 */
+ (void)CANCLE:(NSString *)url;

@end
