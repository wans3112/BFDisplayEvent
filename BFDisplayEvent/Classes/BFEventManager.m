//
//  BFEventManager.m
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2017/4/10.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//

#import "BFEventManager.h"
#import <CTObjectiveCRuntimeAdditions/CTBlockDescription.h>
#import "UIResponder+BFEventManager.h"

@interface BFEventManager ()

@property (nonatomic, weak, readwrite) UIResponder                          *em_target;

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
        self.em_target = target;
    }
    return self;
}

- (void)em_didSelectItemWithEventType:(NSInteger)eventType {

    [self em_didSelectItemWithModelBlock:^(BFEventModel *eventModel) {
        eventModel.eventType = eventType;
    }];
    
}

- (void)em_didSelectItemWithIdentifier:(NSString *)identifier {
   
    [self em_didSelectItemWithModelBlock:^(BFEventModel *eventModel) {
        eventModel.identifier = identifier;
    }];
}

#pragma mark - Getter&&Setter

- (BFEventModelBlock)em_model {
    
    return self.em_target.em_model;
}

- (UIViewController *)em_viewController {
    
    return self.em_target.em_viewController;
}

- (void)setEm_targetValueForKey:(BFSetValueForKeyBlock)em_ValueForKey {}

- (BFSetValueForKeyBlock)em_targetValueForKey {
    return self.em_target.em_valueForKey;
}

- (void)setEm_targetParamForKey:(BFSetValueForKeyBlock)em_targetParamForKey {}

- (BFSetValueForKeyBlock)em_targetParamForKey {
    return self.em_target.em_paramForKey;
}

- (void)em_handleUpdateTargetWithKeysAndValues:(NSArray *)keys eventBlock:(id)eventBlock {
    
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
                    argument = self.em_target;
                }else {
                    argument = self.em_targetValueForKey(argument);
                }
                [invocation setArgument:&argument atIndex:1 + i];
            }
        }
    }
    
    // 执行block
    [invocation invoke];
}

@end
