//
//  BFEventManager.m
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2017/4/10.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//

#import "BFEventManager.h"

@interface BFEventManager ()

@property (nonatomic, strong) id                                   em_View;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wprotocol"

@implementation BFEventManager
#pragma clang diagnostic pop

- (void)didSelectItemWithModel:(BFEventModel *)eventModel {}

- (void)didSelectItemWithModelBlock:(BFEventManagerBlock)eventBlock {}

- (instancetype)initWithTarget:(id)targetView {

    self = [super init];
    if ( self ) {
        self.em_View = targetView;
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
    
    if ([self.em_View isKindOfClass:[UIViewController class]]) {
        return (UIViewController *)self.em_View;
    }
    
    UIView *selfView = (UIView *)self.em_View;
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

@end
