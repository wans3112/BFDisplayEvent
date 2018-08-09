//
//  BFViewObject.m
//  BFDisplayEvent
//
//  Created by wans on 2018/7/13.
//

#import "BFViewObject.h"

@interface BFViewObject ()

@property (nonatomic, weak) id                                   model;

@end

@implementation BFViewObject

- (instancetype)initWithModel:(id)model {
    
    self = [super init];
    if ( self ) {
        self.model = model;
    }
    
    return self;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    
    return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    
    if ( self.model && [self.model respondsToSelector:aSelector] ) {
        return self.model;
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

@end


@implementation NSObject (ModelForView)

+ (instancetype)em_mfv:(id)model {
    return [((BFViewObject *)[self.class alloc]) initWithModel:model];
}

@end
