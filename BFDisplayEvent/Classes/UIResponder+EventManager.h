//
//  UIResponder+EventManager.h
//  Pods
//
//  Created by wans on 2017/4/12.
//
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
 获取model
 */
@property (nonatomic, strong) BFEventModelBlock          em_Model;

/**
 获取事件管理器
 */
@property (nonatomic, strong) BFEventManager             *eventManager;

/**
 初始化获取参数
 */
- (id)em_Setup:(id)instance block:(BFEventManagerBlock)block;


/**
 通过kvc赋值

 @param value 新值
 @param key key
 */
- (void)em_SetValue:(id)value key:(NSString *)key;

@end
