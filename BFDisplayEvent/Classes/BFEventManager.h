//
//  BFEventManager.h
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2017/4/10.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFEventModel.h"
#import "BFDisplayEventProtocol.h"

typedef id (^BFSetValueForKeyBlock)(NSString *key);

/**
 通用事件调用宏，按vc做事件解耦
 */
#define EventInvocationDefault \
if ( [self respondsToSelector:@selector(em_CommonEvents:)]) [self em_CommonEvents:eventModel]; \
NSString *selName = [NSString stringWithFormat:@"em_%@:", NSStringFromClass(self.em_viewController.class)]; \
SEL vcSel = NSSelectorFromString(selName); \
if ( [self respondsToSelector:vcSel]) { \
    [self performSelector:vcSel withObject:eventModel]; \
    return; \
}


typedef BFEventModel* (^BFEventModelBlock)(BFEventManagerBlock eventBlock);

@interface BFEventManager : NSObject<BFEventManagerProtocol>

/**
 通过kvc获取controller的属性
 */
@property (nonatomic, copy)   BFSetValueForKeyBlock                    em_ValueForKey;

/**
 快捷转换
 */
@property (nonatomic, strong) BFEventModelBlock                        em_Model;

/**
 targetView所属的controller
 */
@property (nonatomic, weak)   UIViewController                         *em_viewController;

/**
 与事件管理器绑定的Target
 */
@property (nonatomic, weak, readonly) id                               em_Target;

/**
 初始化

 @param targetView 目标
 @return self
 */
- (instancetype)initWithTarget:(id)targetView;

/**
 将model转化为block

 @param model eventmodel
 @return block
 */
- (BFEventManagerBlock)em_Block:(BFEventModel *)model;

/**
 简单跳转

 @param eventType 事件标志
 */
- (void)em_didSelectItemWithEventType:(NSInteger)eventType;


/**
 通用事件点击事件回调，用于管理多个viewcontroller公用一个事件管理器的情况

 @param eventModel 事件model
 */
- (void)em_CommonEvents:(BFEventModel *)eventModel;

/**
 通过kvc赋值
 
 @param value 新值
 @param key key
 */
- (void)em_SetValue:(id)value key:(NSString *)key;


/**
 更新Target信息

 @param keys target中属性名数组
 @param eventBlock 回调，用于操作更新
 * target
 * @property (nonatomic, strong) NSMutableArray *objects;
 * [self em_handleUpdateTargetWithKeys:@[@"self",@"objects"] eventBlock:^(id target, NSArray *object){
     //TODO: UPDATE
   }];
 */
- (void)em_handleUpdateTargetWithKeys:(NSArray *)keys eventBlock:(id)eventBlock;

@end
