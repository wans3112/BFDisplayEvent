//
//  UIResponder+BFEventManager.m
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2017/4/12.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//

#import "UIResponder+BFEventManager.h"
#import "objc/runtime.h"

static const void *kEventManagerKey = &kEventManagerKey;
static const void *kem_eventManagersKey = &kem_eventManagersKey;
static const void *kem_paramsKey = &kem_paramsKey;
static const void *kem_eventModelKey = &kem_eventModelKey;

@interface UIResponder (BFEventManagers)

/**
 所有的事件管理器
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, BFEventManager*>      *eventManagers;

@end

@implementation UIResponder (BFEventManagers)

- (void)setEventManagers:(NSMutableDictionary<NSString *,BFEventManager *> *)em_eventManagers {
    objc_setAssociatedObject(self.em_viewController, kem_eventManagersKey, em_eventManagers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSString *, BFEventManager*> *)eventManagers {
    NSMutableDictionary *tempManagers = objc_getAssociatedObject(self.em_viewController, kem_eventManagersKey);
    if ( !tempManagers ) {
        tempManagers = @{}.mutableCopy;
        
        self.eventManagers = tempManagers;
    }
    return tempManagers;
}

@end

@implementation UIResponder (BFEventManager)

- (void)em_setTargetValue:(id)value key:(NSString *)key {
    
    [self.em_viewController setValue:value forKey:key];
}

- (void)em_setTargetParams:(id)value key:(NSString *)key {
    
    NSMutableDictionary *em_params = objc_getAssociatedObject(self.em_viewController, kem_paramsKey);
    if ( !em_params ) {
        em_params = [@{} mutableCopy];
    }
    
    em_params[key] = value;
    
    if ( self.em_viewController ) {
        objc_setAssociatedObject(self.em_viewController, kem_paramsKey, em_params, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)em_registerWithClassName:(NSString *)em_ClassName {
    
    BFEventManager *tempEventManager = [((BFEventManager *)[NSClassFromString(em_ClassName) alloc]) initWithTarget:self];

    self.eventManager = tempEventManager;
    self.eventManagers[em_ClassName] = tempEventManager;
}

- (BFEventManager *)eventManagerWithClassName:(NSString *)className {
    
    return self.eventManagers[className];
}

#pragma mark - Getter&&Setter

- (void)setEventManager:(BFEventManager *)eventManager {
    
    objc_setAssociatedObject(self.em_viewController, kEventManagerKey, eventManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BFEventManager *)eventManager {
    
    BFEventManager *tempEventManager = objc_getAssociatedObject(self.em_viewController, kEventManagerKey);
    NSAssert(tempEventManager, @"请先通过'em_registerWithClassName' 注册事件管理器！！");
    
    return tempEventManager;
}

- (UIViewController *)em_viewController {
    
    if ([self isKindOfClass:[UIViewController class]]) {
        return (UIViewController *)self;
    }
    
    id target = self;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

- (void)setEm_viewController:(UIViewController *)em_viewController {}

- (id)em_Setup:(id)instance block:(BFEventManagerBlock)block {
    if (block) {
        block(instance);
    }
    return instance;
}

- (void)setEm_valueForKey:(BFSetValueForKeyBlock)em_ValueForKey {}

- (BFSetValueForKeyBlock)em_valueForKey {
    
    @em_weakify(self)
    id (^icp_block)(NSString *key) = ^id (NSString *key) {
        @em_strongify(self);
        
       return [self.em_viewController valueForKey:key];
    };
    
    return icp_block;
}

- (void)setEm_paramForKey:(BFSetValueForKeyBlock)em_ParamForKey {}

- (BFSetValueForKeyBlock)em_paramForKey {
    
    @em_weakify(self)
    id (^icp_block)(NSString *key) = ^id (NSString *key) {
        @em_strongify(self);
        NSMutableDictionary *em_params = objc_getAssociatedObject(self.em_viewController, kem_paramsKey);
        return em_params[key];
    };
    
    return icp_block;
}

- (void)setEm_model:(BFEventModelBlock)em_Model {}

- (BFEventModelBlock)em_model {

    @em_weakify(self)
    BFEventModel* (^eventModel_block)(BFEventManagerBlock block) = ^BFEventModel* (BFEventManagerBlock block) {
        @em_strongify(self);
        BFEventModel *eventModel = [self em_Setup:[BFEventModel new] block:block];
        self.eventModel = eventModel;
        return eventModel;
    };
    
    return eventModel_block;
    
}

- (void)setEventModel:(BFEventModel *)eventModel {
    objc_setAssociatedObject(self, kem_eventModelKey, eventModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BFEventModel *)eventModel {
    return objc_getAssociatedObject(self, kem_eventModelKey);
}

- (void)setEm_managerForKey:(BFEventManagerForKey)em_ForKey {}

- (BFEventManagerForKey)em_managerForKey {
    
    @em_weakify(self)
    id (^icp_block)(NSString *key) = ^id (NSString *key) {
        @em_strongify(self);
        return self.eventManagers[key];
    };
    
    return icp_block;
}

@end
