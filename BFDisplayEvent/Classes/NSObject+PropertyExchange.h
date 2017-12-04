//
//  NSObject+PropertyExchange.h
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2017/4/10.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PropertyExchange)

/**
 调用替换属性 Invocation property
 */
@property (nonatomic, copy) id(^em_property)(NSString *propertyName);


/**
 返回对象的消息映射
 eg：如果model只有title字段,但model调用title2字段，则在model类现实该方法，并返回字典{@"title2":@"title"}
 
 @return 消息映射字典
 */
- (NSDictionary *)em_exchangeKeyFromPropertyName;

@end
