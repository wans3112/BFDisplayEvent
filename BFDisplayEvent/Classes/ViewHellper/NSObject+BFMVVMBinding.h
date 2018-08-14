//
//  NSObject+BFMVVMBinding.h
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2018/6/27.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//


#import <Foundation/Foundation.h>

/**
 添加绑定监听

 @param Model 监听数据源
 @param ModelPath 需要监听的数据源字段
 @param View 需要更新的对象
 @param ViewPath 需要更新对象字段
 @return 无
 */
#define EMVOObserve(Model, ModelPath, View, ViewPath) \
em_observervoPath(Model, @(((void)Model.ModelPath, #ModelPath)), View, @(((void)View.ViewPath, #ViewPath)))

#define EMObserve(Model, ModelPath, View, ViewPath) \
em_observerPath(Model, @(((void)Model.ModelPath, #ModelPath)), View, @(((void)View.ViewPath, #ViewPath)))

#define EMObserveAction(Model, ModelPath, ViewAction) \
em_observerPathAction(Model, @(((void)Model.ModelPath, #ModelPath)), ViewAction)

#define EMVOObserveAction(Model, ModelPath, ViewAction) \
em_observervoPathAction(Model, @(((void)Model.ModelPath, #ModelPath)), ViewAction)

typedef void(^BFMVVMViewAction)(id);

@interface NSObject (BFMVVMBinding)

@property (nonatomic, copy) NSMutableDictionary *bindingManager;

void em_observerPath(id model, NSString *observerPath, id target, NSString *targetPath);
void em_observervoPath(id model, NSString *observerPath, id target, NSString *targetPath);

void em_observerPathAction(id model, NSString *observerPath, BFMVVMViewAction targetAction);
void em_observervoPathAction(id model, NSString *observerPath, BFMVVMViewAction targetAction);



@end
