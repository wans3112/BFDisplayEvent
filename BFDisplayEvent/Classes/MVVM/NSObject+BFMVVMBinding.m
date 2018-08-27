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
#import "NSObject+BFKeyValue.h"

static void *kPropertyBindingManagerKey = &kPropertyBindingManagerKey;
static void *kPropertyBindingKeyPathKey = &kPropertyBindingKeyPathKey;

@interface NSObject (BFMVVMBindingKeyPath)

/**
 为支持数组格式的model绑定原始path
 */
@property (nonatomic, strong) NSString *em_originalPath;

@end

@implementation NSObject (BFMVVMBindingKeyPath)

#pragma mark - Getter&&Setter

- (void)setEm_originalPath:(NSString *)em_originalPath {
    objc_setAssociatedObject(self, kPropertyBindingKeyPathKey, em_originalPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)em_originalPath {
    return objc_getAssociatedObject(self, kPropertyBindingKeyPathKey);
}

@end

@implementation NSObject (BFMVVMBinding)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
- (id)fetchNewValueWithPath:(NSString *)keyPath {
    
    NSArray *exceptModelKeys = ({
        NSArray *exceptModelKeys;
        NSArray *allKeys = [keyPath componentsSeparatedByString:@"."];
        exceptModelKeys = [allKeys subarrayWithRange:NSMakeRange(1, allKeys.count - 1)];
        exceptModelKeys;
    });
    
    __block id newValue;
    __block BOOL isImpGet = NO;

    @em_weakify(self)
    [exceptModelKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @em_strongify(self)
        SEL getMethod = NSSelectorFromString(obj);
        if ( [self respondsToSelector:getMethod] ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            newValue = [self performSelector:getMethod];
#pragma clang diagnostic pop
            *stop = YES;
            isImpGet = YES;
        }
    }];
    
    if ( !isImpGet ) {
        newValue = [self valueForKeyPath:keyPath];
    }
    
    return newValue;
}

- (void)em_observerPath:(NSString *)observerPath targetAction:(BFMVVMViewAction)targetAction tag:(NSInteger)tag isViewObject:(BOOL)isViewObject {
#pragma clang diagnostic pop

    if ( !observerPath ) return;
    
    NSString *keyPath = observerPath;
    if ( isViewObject ) {
        keyPath = [self realKeyPath:observerPath];
    }
    
    id strOfObj;
    BOOL existArrayObserver = NO;
    BOOL isAlreadyAddObserver = [self.em_bindingManager.allKeys containsObject:keyPath];
    
    if ( [observerPath containsString:@"["] ) {
        existArrayObserver = YES;
        NSRange laskDianRang = [keyPath rangeOfString:@"." options:NSBackwardsSearch];
        NSString *lastPath = [keyPath substringFromIndex:laskDianRang.location + 1];
        NSString *remainPath = [keyPath substringToIndex:laskDianRang.location];
        NSObject *mainObj = [self em_valueForKeyPath:remainPath];
        mainObj.em_originalPath = keyPath;
        
        // 获取监听数组元素的字段
        strOfObj = [mainObj valueForKey:lastPath];
        
        if ( !isAlreadyAddObserver )
            [mainObj addObserver:self forKeyPath:lastPath options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
        

    }else {
        if ( !isAlreadyAddObserver )
            [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    }
    
    if ( !self.em_bindingManager ) {
        self.em_bindingManager = @{}.mutableCopy;
    }
    
    @em_weakify(self)
    void(^updateAction)(BOOL) = ^(BOOL isInitLoad){
        @em_strongify(self)

        if ( !targetAction ) return ;
        
        id newValue;
        if ( existArrayObserver ) {
            newValue = strOfObj;
        }else {
            if ( [self isKindOfClass:BFViewObject.class] ) {
                newValue = [self fetchNewValueWithPath:keyPath];
            }else {
                newValue = [self valueForKeyPath:keyPath];
            }
        }
        
        CTBlockDescription *ct = [[CTBlockDescription alloc] initWithBlock:targetAction];
        NSMethodSignature *methodSignature = ct.blockSignature;
        if ( methodSignature.numberOfArguments - 1 == 1) {
            targetAction(newValue);
        }else if ( methodSignature.numberOfArguments - 1 == 2 ){
            targetAction(newValue,isInitLoad);
        }
    };
    
    updateAction(YES);

    NSMutableDictionary *manager = self.em_bindingManager;
    manager[keyPath] = ({
        NSMutableDictionary *actions = manager[keyPath];
        if ( !actions ) actions = @{}.mutableCopy;
        actions[@(tag)] = [updateAction copy];
        actions;
    });
}

- (NSString *)realKeyPath:(NSString *)keyPath{
    
    NSString *observerPath = keyPath;
    if ( [self isKindOfClass:BFViewObject.class] ) {
        observerPath = [@"model." stringByAppendingString:keyPath];
    }
    return observerPath;
}

- (void)em_observerPath:(NSString *)observerPath target:(id)target targetPath:(NSString *)targetPath isViewObject:(BOOL)isViewObject {
    
    if ( !observerPath ) return;
    
    NSString *keyPath = observerPath;
    if ( isViewObject ) {
        keyPath = [self realKeyPath:observerPath];
    }

    BOOL isAlreadyAddObserver = [self.em_bindingManager.allKeys containsObject:keyPath];
    if ( !isAlreadyAddObserver )
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    
    if ( !self.em_bindingManager ) {
        self.em_bindingManager = @{}.mutableCopy;
    }
    
    @em_weakify(self)
    void(^updateAction)() = ^(){
        @em_strongify(self)
        
        id newValue;
        if ( [self isKindOfClass:BFViewObject.class] ) {
            newValue = [self fetchNewValueWithPath:keyPath];
        }else {
            newValue = [self valueForKeyPath:keyPath];
        }
        [target setValue:newValue forKeyPath:targetPath];
    };
    
    updateAction();
    
    NSMutableDictionary *manager = self.em_bindingManager;
    manager[keyPath] = ({
        NSMutableDictionary *actions = manager[keyPath];
        if ( !actions ) actions = @{}.mutableCopy;
        actions[@0] = updateAction;
        actions;
    });
    
}

void em_observerPath(id model, NSString *observerPath, id target, NSString *targetPath, BOOL isViewObject) {
    
    ((void (*)(id, SEL, NSString *, id, NSString *, BOOL))objc_msgSend)(model, @selector(em_observerPath:target:targetPath:isViewObject:), observerPath, target, targetPath, isViewObject);
}

void em_observerPathAction(id model, NSString *observerPath, BFMVVMViewAction targetAction, NSInteger tag, BOOL isViewObject) {
    
    ((void (*)(id, SEL, NSString *, BFMVVMViewAction, NSInteger, BOOL))objc_msgSend)(model, @selector(em_observerPath:targetAction:tag:isViewObject:), observerPath, targetAction, tag, isViewObject);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSObject *)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ( object.em_originalPath )
        keyPath = object.em_originalPath;
    
    if ( [self.em_bindingManager.allKeys containsObject:keyPath] ) {
        NSMutableDictionary *actions = self.em_bindingManager[keyPath];
        NSLog(@"%@:count:%ld",keyPath,actions.count);
        [actions enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            void(^updateAction)() = obj;
            CTBlockDescription *ct = [[CTBlockDescription alloc] initWithBlock:obj];
            NSMethodSignature *methodSignature = ct.blockSignature;
            if ( methodSignature.numberOfArguments - 1 == 0) {
                updateAction();
            }else if ( methodSignature.numberOfArguments - 1 == 1 ){
                updateAction(NO);
            }
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
