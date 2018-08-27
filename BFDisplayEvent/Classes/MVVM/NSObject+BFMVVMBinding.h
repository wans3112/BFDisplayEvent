//
//  NSObject+BFMVVMBinding.h
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2018/6/27.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//


#import <Foundation/Foundation.h>

/**
 模型字段与视图控件绑定，kvc更新

 @param Model 监听数据源
 @param ModelPath 需要监听的数据源字段
 @param View 需要更新的对象
 @param ViewPath 需要更新对象字段
 
 */

#define EMObserve(Model, ModelPath, View, ViewPath) \
em_observerPath(Model, @(((void)Model.ModelPath, #ModelPath)), View, @(((void)View.ViewPath, #ViewPath)))
//[Model em_observerPath:@(((void)Model.ModelPath, #ModelPath)) target:View targetPath:@(((void)View.ViewPath, #ViewPath))]

/**
 模型字段与视图控件绑定，回调更新

 @param Model 监听数据源
 @param ModelPath 需要监听的数据源字段
 @param ViewAction 数据源更新回调，回调包涵以下两种
 @param Tag 一个path绑定多个action，当数据源更新时全部action同时回调

 1.传入一个参数的block时，
 @param newValue 返回更新的数据
 ^(id newValue){}
 
 2.两个个参数的block时，返回更新的数据和是否
 @param newValue 返回更新的数据
 @param isInitload 是否是第一次默认加载
 ^(id newValue, int isInitload){}

 */

#define EMObserveActionTAG(Model, ModelPath, ViewAction, Tag) \
em_observerPathAction(Model, @(((void)Model.ModelPath, #ModelPath)), ViewAction, Tag)
//[Model em_observerPath:@(((void)Model.ModelPath, #ModelPath)) targetAction:ViewAction tag:Tag]

#define EMObserveAction(Model, ModelPath, ViewAction) \
EMObserveActionTAG(Model, ModelPath, ViewAction, 0)

//#define EMObserve(Model, ModelPath, ViewAction)  ((NSArray *)EMObserveActionTAG(Model, ModelPath, ViewAction, 0))

/**
 模型字段与视图控件绑定，回调更新

 @param Model 监听数据源
 @param ModelPath 需要监听的数据源字段，可传入字符串@"",支持数组格式的path的格式，详情见<NSObject+BFKeyValue.h>
 @param ViewAction 数据源更新回调，回调包涵以下两种
 
 eg:EMObserveActionStr(model, @"array.[5.title", block);
 监听model的数组array的第五个元素submodel的字段title，当title发生改变则执行更新回调block
 
 */
#define EMObserveActionStringTAG(Model, ModelPath, ViewAction, Tag) \
em_observerPathAction(Model, ModelPath, ViewAction, Tag)
//[Model em_observerPath:ModelPath targetAction:ViewAction tag:Tag]
#define EMObserveActionString(Model, ModelPath, ViewAction) \
EMObserveActionStringTAG(Model, ModelPath, ViewAction, 0)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
typedef void(^BFMVVMViewAction)();

@interface NSObject (BFMVVMBinding)

void em_observerPath(id model, NSString *observerPath, id target, NSString *targetPath);

void em_observerPathAction(id model, NSString *observerPath, BFMVVMViewAction targetAction, NSInteger tag);

@end
