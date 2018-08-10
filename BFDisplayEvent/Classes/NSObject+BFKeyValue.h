//
//  NSObject+BFKeyValue.h
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2018/8/9.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (BFKeyValue)

/**
 通过自定义规则path获取value，规则如下：
 
 vc:UIViewController->dataSources:(NSArray<NSArray<Model> *> *)
 获取vc的dataSources数组的弟2个元素（数组）的第三个元素（包涵node的model）的node（node的model）字段的name字段；
 
 入参keyPath:"dataSources.[1.[2.node.name",其中"["表示：左边key是数组，右边是该数组的index，右边必须为整型，大于0；
 调用:[vc em_valueForKeyPath:@"dataSources.[1.[2.node.name"];
 返回:name字段的值

 @param keyPath 自定义规则
 @return 值
 */
- (id)em_valueForKeyPath:(NSString *)keyPath;

/**
 通过自定义规则path设置value
 
 @param value 值
 @param keyPath 自定义规则（同上）
 */
- (void)em_setValue:(id)value forKeyPath:(NSString *)keyPath;

@end
