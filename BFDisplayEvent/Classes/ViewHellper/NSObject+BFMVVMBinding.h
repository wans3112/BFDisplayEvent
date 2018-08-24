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
 @param Tag 多处绑定同一个path
 @return 无
 */

#define EMObserve(Model, ModelPath, View, ViewPath) \
em_observerPath(Model, @(((void)Model.ModelPath, #ModelPath)), View, @(((void)View.ViewPath, #ViewPath)))

#define EMObserveActionTAG(Model, ModelPath, ViewAction, Tag) \
em_observerPathAction(Model, @(((void)Model.ModelPath, #ModelPath)), ViewAction, Tag)

#define EMObserveAction(Model, ModelPath, ViewAction) \
EMObserveActionTAG(Model, ModelPath, ViewAction, 0)



#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
typedef void(^BFMVVMViewAction)();

@interface NSObject (BFMVVMBinding)

@property (nonatomic, copy) NSMutableDictionary *em_bindingManager;

void em_observerPath(id model, NSString *observerPath, id target, NSString *targetPath);

void em_observerPathAction(id model, NSString *observerPath, BFMVVMViewAction targetAction, NSInteger tag);



@end
