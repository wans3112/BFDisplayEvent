//
//  UIResponder+EventManager.h
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2017/4/12.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFEventManager.h"

typedef id (^BFSetValueForKeyBlock)(NSString *key);

@interface UIResponder (EventManager)

/**
 targetView所属的controller
 */
@property (nonatomic, weak)   UIViewController           *em_viewController;


/**
 通过kvc获取controller的属性
 */
@property (nonatomic, copy)   BFSetValueForKeyBlock      em_ValueForKey;

/**
 通过key获取controller params
 */
@property (nonatomic, copy)   BFSetValueForKeyBlock      em_ParamForKey;

/**
 获取model
 */
@property (nonatomic, strong) BFEventModelBlock          em_Model;

/**
 获取事件管理器,默认选择最后一个
 */
@property (nonatomic, strong) BFEventManager             *eventManager;

/**
 事件管理器，当注册多个事件管理器时，通过key取eventManager
 */
@property (nonatomic, strong) BFSetValueForKeyBlock      em_ForKey;


/**
 给当前target注册时事件管理器

 @param em_ClassName 事件管理器子类
 @return 事件管理器
 */
- (BFEventManager *)em_RegisterWithClassName:(NSString *)em_ClassName;

/**
 通过kvc赋值

 @param value 新值
 @param key key
 */
- (void)em_SetValue:(id)value key:(NSString *)key;

/**
 给target设置参数
 
 @param value 新值
 @param key key
 */
- (void)em_SetParamsValue:(id)value key:(NSString *)key;

@end
