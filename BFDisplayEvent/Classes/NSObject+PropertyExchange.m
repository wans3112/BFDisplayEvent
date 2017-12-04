//
//  NSObject+PropertyExchange.m
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2017/4/10.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//

#import "NSObject+PropertyExchange.h"
#import "objc/runtime.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

static void *kPropertyNameKey = &kPropertyNameKey;

@implementation NSObject (_PropertyExchange)

+ (void)load {
    
    /**
     替换系统的消息转发方法
     */
    Method fromMethod = class_getInstanceMethod([self class], @selector(methodSignatureForSelector:));
    Method toMethod = class_getInstanceMethod([self class], @selector(em_methodSignatureForSelector:));
    
    if (!class_addMethod([self class], @selector(em_methodSignatureForSelector:), method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {
        method_exchangeImplementations(fromMethod, toMethod);
    }
    
    fromMethod = class_getInstanceMethod([self class], @selector(forwardInvocation:));
    toMethod = class_getInstanceMethod([self class], @selector(em_forwardInvocation:));
    
    if (!class_addMethod([self class], @selector(em_forwardInvocation:), method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {
        method_exchangeImplementations(fromMethod, toMethod);
    }
}

/**
 消息转发
 
 @param aSelector 方法
 @return 调用方法的签名
 */
- (NSMethodSignature *)em_methodSignatureForSelector:(SEL)aSelector {
    
    if ( ![self respondsToSelector:@selector(em_exchangeKeyFromPropertyName)] ) {
        return [self em_methodSignatureForSelector:aSelector];
    }
    
    NSString *propertyName = NSStringFromSelector(aSelector);
    
    NSDictionary *propertyDic = [self em_exchangeKeyFromPropertyName];
    
    if ( propertyDic && [propertyDic.allKeys containsObject:propertyName] ) {
        
        NSString *targetPropertyName = [NSString stringWithFormat:@"em_%@",propertyName];
        if ( ![self respondsToSelector:NSSelectorFromString(targetPropertyName)] ) {
            // 如果没有em_重写属性，则用model原属性替换
            targetPropertyName = [propertyDic objectForKey:propertyName];
        }
        
        SEL targetselector = NSSelectorFromString(targetPropertyName);
        NSMethodSignature *methodSignature = [[self class] instanceMethodSignatureForSelector:targetselector];
        objc_setAssociatedObject(methodSignature, kPropertyNameKey, targetPropertyName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        return methodSignature;
    }
    
    return [self em_methodSignatureForSelector:aSelector];
}

/**
 获取消息签名，再消息调用
 
 @param anInvocation 方法
 */
- (void)em_forwardInvocation:(NSInvocation *)anInvocation {
    
    NSString *originalPropertyName = objc_getAssociatedObject(anInvocation.methodSignature, kPropertyNameKey);
    
    if ( originalPropertyName ) {
        SEL selector = NSSelectorFromString(originalPropertyName);
        anInvocation.selector = selector;
        [anInvocation invokeWithTarget:self];
    }
    
}

#pragma mark - Getter&&Setter

- (id(^)(NSString *))em_property {
    
    __weak typeof(self) weakSelf = self;
    id (^icp_block)(NSString *propertyName) = ^id (NSString *propertyName) {
        __strong typeof(self) strongSelf = weakSelf;
        
        SEL sel = NSSelectorFromString(propertyName);
        if ( !sel ) return nil;
        SuppressPerformSelectorLeakWarning(
                                           return [strongSelf performSelector:NSSelectorFromString(propertyName)];
                                           );
    };
    
    return icp_block;
}

- (void)setEm_property:(id (^)(NSString *))em_property {}

@end

