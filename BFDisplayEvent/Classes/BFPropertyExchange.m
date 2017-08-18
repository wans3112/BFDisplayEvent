//
//  BFPropertyExchange.m
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2017/4/10.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//

#import "BFPropertyExchange.h"
#import "objc/runtime.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

static void *kPropertyNameKey = &kPropertyNameKey;

@implementation NSObject (PropertyExchange)

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

- (void)setIcp:(id (^)(NSString *))icp {}

@end


@implementation BFPropertyExchange

- (NSDictionary *)em_exchangeKeyFromPropertyName {

    return nil;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return nil;
}

/**
 消息转发
 
 @param aSelector 方法
 @return 调用方法的描述
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    NSString *propertyName = NSStringFromSelector(aSelector);
    
    NSDictionary *propertyDic = [self em_exchangeKeyFromPropertyName];
    
    NSMethodSignature* (^doGetMethodSignature)(NSString *propertyName) = ^(NSString *propertyName){
    
        NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:"v@:"];
        objc_setAssociatedObject(methodSignature, kPropertyNameKey, propertyName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        return  [NSMethodSignature signatureWithObjCTypes:"v@:"];
    };
    
    if ( [propertyDic.allKeys containsObject:propertyName] ) {
        
        NSString *targetPropertyName = [NSString stringWithFormat:@"em_%@",propertyName];
        if ( ![self respondsToSelector:NSSelectorFromString(targetPropertyName)] ) {
            // 如果没有em_重写属性，则用model原属性替换
            targetPropertyName = [propertyDic objectForKey:propertyName];
        }
        
        return doGetMethodSignature(targetPropertyName);
    }
    
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    NSString *originalPropertyName = objc_getAssociatedObject(anInvocation.methodSignature, kPropertyNameKey);
    
    if ( originalPropertyName ) {
        anInvocation.selector = NSSelectorFromString(originalPropertyName);
        [anInvocation invokeWithTarget:self];
    }
    
}

- (void)dealloc {
    NSLog(@"\n %@ is dealloc \n",[self class]);
}

@end
