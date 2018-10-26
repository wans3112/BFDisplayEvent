//
//  BFViewObject.m
//  BFDisplayEvent
//
//  Created by wans on 2018/7/13.
//

#import "BFViewObject.h"

@interface BFViewObject ()

@property (nonatomic, strong) id                                   entityModel;

@end

@implementation BFViewObject

- (instancetype)initWithModel:(id)entityModel {
    
    self = [super init];
    if ( self ) {
        self.entityModel = entityModel;
    }
    
    return self;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    
    return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    
    if ( self.entityModel && [self.entityModel respondsToSelector:aSelector] ) {
        return self.entityModel;
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

- (id)valueForUndefinedKey:(NSString *)key {
    
    return [self.entityModel valueForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    [self.entityModel setValue:value forUndefinedKey:key];
}

@end


@implementation NSObject (ModelForView)

+ (instancetype)em_mfv:(id)model {
    return [((BFViewObject *)[self.class alloc]) initWithModel:model];
}

@end
