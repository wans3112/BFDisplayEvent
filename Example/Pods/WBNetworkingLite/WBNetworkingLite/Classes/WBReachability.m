//
//  WBHMReachability.m
//  Pods
//
//  Created by wans on 2017/9/19.
//
//

#import "WBReachability.h"
#import "objc/runtime.h"

@implementation WBReachability

static Reachability *reach;

static NSMutableSet *targets;

+ (NSMutableSet *)targets {
    if ( !targets ) {
        targets = [NSMutableSet set];
    }
    return targets;
}

+ (void)addTarget:(id)target reachableBlock:(void(^)(NetworkStatus status))reachableBlock {
    
    [[[self class] targets] addObject:target];
    
    objc_setAssociatedObject(target, "Reachability_target", reachableBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if ( reach ) return;
    
    reach = [Reachability reachabilityForInternetConnection];
    reach.reachableBlock = ^(Reachability *reach) {
        for (id thetarget in [[self class] targets]) {
            void(^target_reachableBlock)(NetworkStatus status) = objc_getAssociatedObject(thetarget, "Reachability_target");
            if ( target_reachableBlock ) target_reachableBlock([reach currentReachabilityStatus]);
        }
    };
    reach.unreachableBlock = ^(Reachability*reach) {
        for (id thetarget in [[self class] targets]) {
            void(^target_reachableBlock)(NetworkStatus status) = objc_getAssociatedObject(thetarget, "Reachability_target");
            if ( target_reachableBlock ) target_reachableBlock([reach currentReachabilityStatus]);
        }
    };
    
    [reach startNotifier];
}

+ (void)removeTarget:(id)target {
    
    [[[self class] targets] removeObject:target];

    if ( [[self class] targets].count == 0 ) {
        [[self class] stopNotifier];
    }
}

+ (void)stopNotifier {
    
    [reach stopNotifier];
    reach = nil;
}

+ (BOOL)isReachable {
    
    return [Reachability reachabilityForInternetConnection].isReachable;
}

+ (BOOL)isReachableViaWiFi {

    return  [Reachability reachabilityForInternetConnection].isReachableViaWiFi;
}

+ (BOOL)isReachableViaWWAN {
    
    return  [Reachability reachabilityForInternetConnection].isReachableViaWWAN;
}

@end
