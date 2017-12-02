//
//  UIResponder+EventManager.m
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2017/4/12.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//

#import "UIResponder+EventManager.h"
#import "objc/runtime.h"

static const void *kEventManagerKey = &kEventManagerKey;
static const void *kem_eventManagersKey = &kem_eventManagersKey;
static const void *kem_paramsKey = &kem_paramsKey;

@interface UIResponder (_EventManager)

/**
 所有的事件管理器
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, BFEventManager*>      *em_eventManagers;

@end

@implementation UIResponder (_EventManager)

- (void)setEm_eventManagers:(NSMutableDictionary<NSString *,BFEventManager *> *)em_eventManagers {
    objc_setAssociatedObject(self.em_viewController, kem_eventManagersKey, em_eventManagers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableDictionary<NSString *, BFEventManager*> *)em_eventManagers {
    NSMutableDictionary *em_eventManagers = objc_getAssociatedObject(self.em_viewController, kem_eventManagersKey);
    if ( !em_eventManagers ) {
        em_eventManagers = @{}.mutableCopy;
        
        self.em_eventManagers = em_eventManagers;
    }
    return em_eventManagers;
}

@end

@implementation UIResponder (EventManager)

- (void)em_SetValue:(id)value key:(NSString *)key {
    
    [self.em_viewController setValue:value forKey:key];
}

- (void)em_SetParamsValue:(id)value key:(NSString *)key {
    
    NSMutableDictionary *em_params = objc_getAssociatedObject(self.em_viewController, kem_paramsKey);
    if ( !em_params ) {
        em_params = [@{} mutableCopy];
    }
    
    em_params[key] = value;
    
    if ( self.em_viewController ) {
        objc_setAssociatedObject(self.em_viewController, "em_params", em_params, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (BFEventManager *)em_RegisterWithClassName:(NSString *)em_ClassName {
    
    BFEventManager *tempEventManager = [[NSClassFromString(em_ClassName) alloc] initWithTarget:self];

    self.eventManager = tempEventManager;
    self.em_eventManagers[em_ClassName] = tempEventManager;
    
    return tempEventManager;
}

#pragma mark - Getter&&Setter

- (void)setEventManager:(BFEventManager *)eventManager {
    
    objc_setAssociatedObject(self.em_viewController, kEventManagerKey, eventManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BFEventManager *)eventManager {
    
    BFEventManager *tempEventManager = objc_getAssociatedObject(self.em_viewController, kEventManagerKey);
    NSAssert(tempEventManager, @"请先通过'registerEventManagerClassName' 注册事件管理器！！");
    
    return tempEventManager;
}

- (UIViewController *)em_viewController {
    
    if ([self isKindOfClass:[UIViewController class]]) {
        return (UIViewController *)self;
    }
    
    UIView *selfView = (UIView *)self;
    for (UIView *view = selfView; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)setEm_viewController:(UIViewController *)em_viewController {}

- (id)em_Setup:(id)instance block:(BFEventManagerBlock)block {
    if (block) {
        block(instance);
    }
    return instance;
}

- (void)setEm_ValueForKey:(BFSetValueForKeyBlock)em_ValueForKey {}

- (BFSetValueForKeyBlock)em_ValueForKey {
    
    __weak typeof(self) weakSelf = self;
    id (^icp_block)(NSString *key) = ^id (NSString *key) {
        __strong typeof(self) strongSelf = weakSelf;
        
       return [strongSelf.em_viewController valueForKey:key];
    };
    
    return icp_block;
}

- (void)setEm_ParamForKey:(BFSetValueForKeyBlock)em_ParamForKey {}

- (BFSetValueForKeyBlock)em_ParamForKey {
    
    __weak typeof(self) weakSelf = self;
    id (^icp_block)(NSString *key) = ^id (NSString *key) {
        __strong typeof(self) strongSelf = weakSelf;
        NSMutableDictionary *em_params = objc_getAssociatedObject(strongSelf.em_viewController, kem_paramsKey);
        return em_params[key];
    };
    
    return icp_block;
}

- (void)setEm_Model:(BFEventModelBlock)em_Model {}

- (BFEventModelBlock)em_Model {
    
    __weak typeof(self) weakSelf = self;
    BFEventModel* (^eventModel_block)(BFEventManagerBlock block) = ^BFEventModel* (BFEventManagerBlock block) {
        __strong typeof(self) strongSelf = weakSelf;
        
        return [strongSelf em_Setup:[BFEventModel new] block:block];
    };
    
    return eventModel_block;
    
}

- (void)setEm_ForKey:(BFSetValueForKeyBlock)em_ForKey {}

- (BFSetValueForKeyBlock)em_ForKey {
    
    __weak typeof(self) weakSelf = self;
    id (^icp_block)(NSString *key) = ^id (NSString *key) {
        __strong typeof(self) strongSelf = weakSelf;
        return strongSelf.em_eventManagers[key];
    };
    
    return icp_block;
}

@end
