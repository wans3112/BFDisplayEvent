//
//  BFEventManager.m
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2017/4/10.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//

#import "BFEventManager.h"
#import <CTObjectiveCRuntimeAdditions/CTBlockDescription.h>

@interface BFEventManager ()

@property (nonatomic, strong, readwrite) id                                   em_Target;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wprotocol"

@implementation BFEventManager
#pragma clang diagnostic pop

- (void)didSelectItemWithModel:(BFEventModel *)eventModel {}

- (void)didSelectItemWithModelBlock:(BFEventManagerBlock)eventBlock {}

- (instancetype)initWithTarget:(id)target {

    self = [super init];
    if ( self ) {
        self.em_Target = target;
    }
    return self;
}

- (void)em_didSelectItemWithEventType:(NSInteger)eventType {

    [self em_didSelectItemWithModelBlock:^(BFEventModel *eventModel) {
        eventModel.eventType = eventType;
    }];
    
}

- (id)em_Setup:(id)instance block:(BFEventManagerBlock)block {
    if (block) {
        block(instance);
    }
    return instance;
}

- (void)em_SetValue:(id)value key:(NSString *)key {
    
    [self.em_viewController setValue:value forKey:key];
}

#pragma mark - Getter&&Setter

- (BFEventManagerBlock)em_Block:(BFEventModel *)theModel {

    return  ^(BFEventModel *model) {
        model = theModel;
    };;
}

- (BFEventModelBlock)em_Model {

    __weak typeof(self) weakSelf = self;
    BFEventModel* (^eventModel_block)(BFEventManagerBlock block) = ^BFEventModel* (BFEventManagerBlock block) {
        __strong typeof(self) strongSelf = weakSelf;
        
        return [strongSelf em_Setup:[BFEventModel new] block:block];
    };
    
    return eventModel_block;
    
}

- (UIViewController *)em_viewController {
    
    if ([self.em_Target isKindOfClass:[UIViewController class]]) {
        return (UIViewController *)self.em_Target;
    }
    
    UIView *selfView = (UIView *)self.em_Target;
    for (UIView *view = selfView; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
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

- (void)em_handleUpdateTargetWithKeys:(NSArray *)keys eventBlock:(id)eventBlock {
    
    if (eventBlock == nil) return;
    id target = [eventBlock  copy];
    
    CTBlockDescription *ct = [[CTBlockDescription alloc] initWithBlock:target];
    NSMethodSignature *methodSignature = ct.blockSignature;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.target = target;
    
    // invocation 有1个隐藏参数，所以 argument 从1开始
    if ([keys isKindOfClass:[NSArray class]]) {
        NSInteger count = MIN(keys.count, methodSignature.numberOfArguments - 1);
        for (int i = 0; i < count; i++) {
            const char *type = [methodSignature getArgumentTypeAtIndex:1 + i];
            NSString *typeStr = [NSString stringWithUTF8String:type];
            if ([typeStr containsString:@"\""]) {
                type = [typeStr substringToIndex:1].UTF8String;
            }
            
            // 需要做参数类型判断然后解析成对应类型，这里默认所有参数均为OC对象
            if (strcmp(type, "@") == 0) {
                id argument = keys[i];
                
                if ( [argument isEqualToString:@"self"] ) {
                    argument = self.em_viewController;
                }else {
                    argument = self.em_ValueForKey(argument);
                }
                [invocation setArgument:&argument atIndex:1 + i];
            }
        }
    }
    
    // 执行block
    [invocation invoke];
}

@end
