//
//  WBHMReachability.h
//  Pods
//
//  Created by wans on 2017/9/19.
//
//

#import <Foundation/Foundation.h>
#import <Reachability/Reachability.h>

@interface WBReachability : NSObject

/**
 网络是否可用
 
 @return 网络状态
 */
+ (BOOL)isReachable;

/**
 添加监听网络状态

 @param target 目标
 @param reachableBlock 网络变化回调
 */
+ (void)addTarget:(id)target reachableBlock:(void(^)(NetworkStatus status))reachableBlock;

/**
 移除网络监听

 @param target 目标
 */
+ (void)removeTarget:(id)target;

/**
 停止所有网络监听
 */
+ (void)stopNotifier;


/**
 是否是wifi

 @return wifi
 */
+ (BOOL)isReachableViaWiFi;

/**
 是否是3g/2g
 
 @return wifi
 */
+ (BOOL)isReachableViaWWAN;

@end
