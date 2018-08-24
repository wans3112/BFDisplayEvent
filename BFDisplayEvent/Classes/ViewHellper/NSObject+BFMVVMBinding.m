//
//  NSObject+BFMVVMBinding.m
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2018/6/27.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//

#import "NSObject+BFMVVMBinding.h"
#import "objc/runtime.h"
#import "objc/message.h"
#import "BFViewObject.h"
#import <CTObjectiveCRuntimeAdditions/CTBlockDescription.h>

static void *kPropertyBindingManagerKey = &kPropertyBindingManagerKey;

@implementation NSObject (BFMVVMBinding)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
- (void)fetchNewValue:(id __autoreleasing *)newValue withPath:(NSString *)keyPath {
    
    NSArray *exceptModelKeys = ({
        NSArray *exceptModelKeys;
        NSArray *allKeys = [keyPath componentsSeparatedByString:@"."];
        exceptModelKeys = [allKeys subarrayWithRange:NSMakeRange(1, allKeys.count - 1)];
        exceptModelKeys;
    });
    
    __block BOOL isImpGet = NO;
    [exceptModelKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL getMethod = NSSelectorFromString(obj);
        if ( [self respondsToSelector:getMethod] ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            *newValue = [self performSelector:getMethod];
#pragma clang diagnostic pop
            *stop = YES;
            isImpGet = YES;
        }
    }];
    
    if ( !isImpGet ) {
        *newValue = [self valueForKeyPath:keyPath];
    }
}

- (void)em_observerPath:(NSString *)observerPath targetAction:(BFMVVMViewAction)targetAction tag:(NSInteger)tag {
#pragma clang diagnostic pop

    if ( !observerPath ) return;
    
    NSString *keyPath = [self realKeyPath:observerPath];

    __weak typeof(self) weakSelf = self;
    [self addObserver:weakSelf forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    
    if ( !self.em_bindingManager ) {
        self.em_bindingManager = @{}.mutableCopy;
    }
    
    void(^updateAction)(BOOL) = ^(BOOL isInitLoad){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ( targetAction ){
            
            id newValue;
            if ( [strongSelf isKindOfClass:BFViewObject.class] ) {
                [strongSelf fetchNewValue:&newValue withPath:observerPath];
            }else {
                newValue = [strongSelf valueForKeyPath:keyPath];
            }
            
            CTBlockDescription *ct = [[CTBlockDescription alloc] initWithBlock:targetAction];
            NSMethodSignature *methodSignature = ct.blockSignature;
            if ( methodSignature.numberOfArguments - 1 == 1) {
                targetAction(newValue);
            }else if ( methodSignature.numberOfArguments - 1 == 2 ){
                targetAction(newValue,isInitLoad);
            }
        }
    };
    
    updateAction(YES);
    
    NSMutableDictionary *manager = self.em_bindingManager;
    NSMutableDictionary *actions = manager[keyPath];
    
    if ( !actions ) actions = @{}.mutableCopy;
    
    actions[@(tag)] = updateAction;
    manager[keyPath] = actions;
    self.em_bindingManager = manager;
}

- (NSString *)realKeyPath:(NSString *)keyPath{
    
    NSString *observerPath = keyPath;
    if ( [self isKindOfClass:BFViewObject.class] ) {
        observerPath = [@"model." stringByAppendingString:keyPath];
    }
    return observerPath;
}

- (void)em_observerPath:(NSString *)observerPath target:(id)target targetPath:(NSString *)targetPath {
    
    if ( !observerPath ) return;
    
    __weak typeof(self) weakSelf = self;
    [self addObserver:weakSelf forKeyPath:observerPath options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    
    if ( !self.em_bindingManager ) {
        self.em_bindingManager = @{}.mutableCopy;
    }
    
    NSString *keyPath = [self realKeyPath:observerPath];
    
    void(^updateAction)() = ^(){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        id newValue;
        if ( [strongSelf isKindOfClass:BFViewObject.class] ) {
            [strongSelf fetchNewValue:&newValue withPath:observerPath];
        }else {
            newValue = [strongSelf valueForKeyPath:keyPath];
        }
        [target setValue:newValue forKeyPath:targetPath];
    };
    
    updateAction();
    
    NSMutableDictionary *manager = self.em_bindingManager;
    NSMutableDictionary *actions = manager[keyPath];
    if ( !actions ) {
        actions = @{}.mutableCopy;
    }

    actions[@0] = updateAction;
    manager[keyPath] = actions;
    self.em_bindingManager = manager;
}

void em_observerPath(id model, NSString *observerPath, id target, NSString *targetPath) {
    
    ((void (*)(id, SEL, NSString *, id, NSString *))objc_msgSend)(model, @selector(em_observerPath:target:targetPath:), observerPath, target, targetPath);
}

void em_observerPathAction(id model, NSString *observerPath, BFMVVMViewAction targetAction, NSInteger tag) {
    
    ((void (*)(id, SEL, NSString *, BFMVVMViewAction, NSInteger))objc_msgSend)(model, @selector(em_observerPath:targetAction:tag:), observerPath, targetAction, tag);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ( [self.em_bindingManager.allKeys containsObject:keyPath] ) {
        NSDictionary *actions = self.em_bindingManager[keyPath];
        NSLog(@"%@:count:%ld",keyPath,actions.count);
        [actions enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            void(^updateAction)(BOOL) = obj;
            !updateAction ?: updateAction(NO);
        }];
    }
}

#pragma mark - Getter&&Setter

- (void)setEm_bindingManager:(NSMutableDictionary *)em_bindingManager {
    objc_setAssociatedObject(self, kPropertyBindingManagerKey, em_bindingManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)em_bindingManager {
    return objc_getAssociatedObject(self, kPropertyBindingManagerKey);
}

#pragma mark - Swizzle

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method method1 = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
        Method method2 = class_getInstanceMethod([self class], @selector(deallocSwizzle));
        method_exchangeImplementations(method1, method2);
    });
    
}

- (void)deallocSwizzle {
    
    // 销毁时移除所有监听
    if ( self.em_bindingManager.count > 0 ) {
        __unsafe_unretained NSObject *weakSelf = self;
        [self.em_bindingManager enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            __strong NSObject *strongSelf = weakSelf;
            
            [strongSelf removeObserver:strongSelf forKeyPath:key context:(__bridge void *)strongSelf];
            [strongSelf.em_bindingManager removeObjectForKey:key];
        }];
        self.em_bindingManager = nil;
        weakSelf = nil;
    }

    [self deallocSwizzle];
}

@end
