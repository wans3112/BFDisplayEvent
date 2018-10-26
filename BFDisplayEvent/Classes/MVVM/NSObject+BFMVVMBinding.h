//
//  NSObject+BFMVVMBinding.h
//  HomePage https://github.com/wans3112/BFDisplayEvent
//  实现view与model双向绑定
//
//  Created by wans on 2018/6/27.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//


#import <Foundation/Foundation.h>

/**
 模型字段与视图控件绑定，kvc更新

 @param Model 监听数据源
 @param ModelPath 需要监听的数据源字段
 @param Target 需要更新的对象
 @param TargetPath 需要更新对象字段
 
 */

#define EMObserve(Model, ModelPath, Target, TargetPath) \
em_observerPath(Model, @(((void)Model.ModelPath, #ModelPath)), Target, @(((void)Target.TargetPath, #TargetPath)), NO)

#define EMVOObserve(Model, ModelPath, Target, TargetPath) \
em_observerPath(Model, @(((void)Model.ModelPath, #ModelPath)), Target, @(((void)Target.TargetPath, #TargetPath)), YES)

#define EMObserveOnlyNotify(Model, ModelPath, Target, TargetPath) \
em_observerPathOnlyNotify(Model, @(((void)Model.ModelPath, #ModelPath)), Target, @(((void)Target.TargetPath, #TargetPath)), NO, YES)

/**
 模型字段与视图控件绑定，回调更新
 
 @param Model 监听数据源
 @param ModelPath 需要监听的数据源字段
 @param TargetAction 数据源更新回调，回调包涵以下两种
 @param Tag 一个path绑定多个action，当数据源更新时全部action同时回调
 @param IsViewObject 是否为ViewObject
 
 1.传入一个参数的block时，
 @param newValue 返回更新的数据
 ^(id newValue){}
 
 2.两个个参数的block时，返回更新的数据和是否
 @param newValue 返回更新的数据
 @param isInitload 是否是第一次默认加载
 ^(id newValue, int isInitload){}
 
 */

#define EMObserveActionCommon(Model, ModelPath, TargetAction, Tag, IsTargetObject) \
em_observerPathAction(Model, @(((void)Model.ModelPath, #ModelPath)), TargetAction, Tag, IsTargetObject)

#define EMObserveActionTag(Model, ModelPath, TargetAction, Tag) EMObserveActionCommon(Model, ModelPath, TargetAction, Tag, NO)
#define EMObserveAction(Model, ModelPath, TargetAction) EMObserveActionCommon(Model, ModelPath, TargetAction, 0, NO)

/**
 For TargetObject
 */
#define EMVOObserveActionTag(Model, ModelPath, TargetAction, Tag) EMObserveActionCommon(Model, ModelPath, TargetAction, Tag, YES)
#define EMVOObserveAction(Model, ModelPath, TargetAction) EMObserveActionCommon(Model, ModelPath, TargetAction, 0, YES)
#define EMVOObserveActionTag(Model, ModelPath, TargetAction, Tag) EMObserveActionCommon(Model, ModelPath, TargetAction, Tag, YES)

#define EMVOObserveStringAction(Model, ModelPath, TargetAction) \
em_observerPathAction(Model, ModelPath, TargetAction, 0, YES)


/**
 模型字段与视图控件绑定，回调更新
 
 @param Model 监听数据源
 @param ModelPath 需要监听的数据源字段，可传入字符串@"",支持数组格式的path的格式，详情见<NSObject+BFKeyValue.h>
 @param ViewAction 数据源更新回调，回调包涵以下两种
 
 eg:EMObserveActionStr(model, @"array.[5.title", block);
 监听model的数组array的第五个元素submodel的字段title，当title发生改变则执行更新回调block
 
 */
#define EMObserveActionString(Model, ModelPath, TargetAction, Tag, IsTargetObject) em_observerPathAction(Model, ModelPath, TargetAction, Tag, IsTargetObject)
#define EMObserveActionStringTag(Model, ModelPath, TargetAction, Tag) EMObserveActionString(Model, ModelPath, TargetAction, Tag, NO)

#define EMObserveString(Model, ModelPath, TargetAction, IsTargetObject) em_observerPath(Model, ModelPath, TargetAction, IsTargetObject)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
typedef void(^BFMVVMAction)();

@interface NSObject (BFMVVMBinding)

void em_observerPath(id model, NSString *observerPath, id target, NSString *targetPath, BOOL isTargetObject);
void em_observerPathOnlyNotify(id model, NSString *observerPath, id target, NSString *targetPath, BOOL isTargetObject, BOOL isOnlyNotify);

void em_observerPathAction(id model, NSString *observerPath, BFMVVMAction targetAction, NSInteger tag, BOOL isTargetObject);

@end
