//
//  UIResponder+EventManager.m
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2017/4/12.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//

#import "UIResponder+EventManager.h"
#import "objc/runtime.h"

static void *kEventManagerKey = &kEventManagerKey;

@implementation UIResponder (EventManager)

- (void)em_SetValue:(id)value key:(NSString *)key {
    
    [self.em_viewController setValue:value forKey:key];
}

- (void)em_SetParamsValue:(id)value key:(NSString *)key {
    
    NSMutableDictionary *em_params = objc_getAssociatedObject(self.em_viewController, "em_params");
    if ( !em_params ) {
        em_params = [@{} mutableCopy];
    }
    
    em_params[key] = value;
    
    if ( self.em_viewController ) {
        objc_setAssociatedObject(self.em_viewController, "em_params", em_params, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)setEm_params:(NSMutableDictionary *)em_params {
    
    NSMutableDictionary *em_params_temp = objc_getAssociatedObject(self.em_viewController, "em_params");
    if ( !em_params_temp ) {
        em_params_temp = [@{} mutableCopy];
        
        if ( self.em_viewController ) {
            objc_setAssociatedObject(self.em_viewController, "em_params", em_params_temp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}
- (NSMutableDictionary *)em_params {
    
    NSMutableDictionary *em_params_temp = objc_getAssociatedObject(self.em_viewController, "em_params");
    if ( !em_params_temp ) {
        em_params_temp = [@{} mutableCopy];
        
        if ( self.em_viewController ) {
            objc_setAssociatedObject(self.em_viewController, "em_params", em_params_temp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
}
#pragma mark - Getter&&Setter

- (BFEventManager *)eventManager {
    
    BFEventManager *tempEventManager = objc_getAssociatedObject(self, kEventManagerKey);
    if ( !tempEventManager ) {
        
        UIViewController<BFEventManagerProtocol> *controller = (UIViewController<BFEventManagerProtocol> *)self.em_viewController;
        
        if ( [controller respondsToSelector:@selector(em_eventManagerWithPropertName)]) {
            
            NSString *propertyName = [controller em_eventManagerWithPropertName];
            
            tempEventManager =  [controller valueForKey:propertyName];
            
        } else {
        
            unsigned int propertCount = 0;
            objc_property_t *properts = class_copyPropertyList(controller.class, &propertCount);
            for (int i = 0; i < propertCount; i++) {
                objc_property_t property = properts[i];
                NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
//                NSString *property_Attributes = [NSString stringWithUTF8String:property_getAttributes(property)];

                id tempPropert = [controller valueForKey:propertyName];
                if ( tempPropert && [tempPropert isKindOfClass:[BFEventManager class]] ) {
                    tempEventManager =  tempPropert;
                    break;
                }
            }
            free(properts);
        }
        
        objc_setAssociatedObject(self, kEventManagerKey, tempEventManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
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

- (void)setEventManager:(BFEventManager *)eventManager {}
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
        NSMutableDictionary *em_params = objc_getAssociatedObject(strongSelf.em_viewController, "em_params");
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

@end
