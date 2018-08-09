//
//  NSObject+BFKeyValue.m
//  BFDisplayEvent
//
//  Created by wans on 2018/8/9.
//

#import "NSObject+BFKeyValue.h"

@implementation NSObject (BFKeyValue)

- (id)em_valueForKeyPath:(NSString *)keyPath {
    
    __block id model = self;
    
    if ( ![keyPath containsString:@"."] ) {
        [self targetModelWithKey:keyPath model:&model];
        return model;
    }
    
    NSArray *tempArray = [keyPath componentsSeparatedByString:@"."];

    __weak typeof(self) weakSelf = self;
    [tempArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        
        __strong typeof(self) strongSelf = weakSelf;
        if ( ![strongSelf targetModelWithKey:key model:&model] ) {
            *stop = YES ;
            model = nil;
        }
    }];
    
    if ( !model ) {
        NSLog(@"keypath:%@ 不合法", keyPath);
    }
    
    return model;
}

- (void)em_setValue:(id)value forKeyPath:(NSString *)keyPath {
    
    __block id model = self;
    
    if ( ![keyPath containsString:@"."] ) {
        [self targetModelWithKey:keyPath model:&model];
        return;
    }
    
    NSArray *subPaths = [keyPath componentsSeparatedByString:@"."];
    NSArray *tempArray = [subPaths subarrayWithRange:NSMakeRange(0, subPaths.count - 1)].copy;
    
    __weak typeof(self) weakSelf = self;
    [tempArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(self) strongSelf = weakSelf;
        if ( ![strongSelf targetModelWithKey:key model:&model] ) {
            *stop = YES ;
            model = nil;
        }
    }];
    
    if ( !model ) {
        NSLog(@"keypath:%@ 不合法", keyPath);
        return;
    }
    
    [model setValue:value forKey:subPaths.lastObject];
}


/**
 字符串是否可以被转化成数字

 @param string 字符
 @return 数字
 */
- (BOOL)isValidInt:(NSString *)string {
    
    NSScanner *scan = [NSScanner scannerWithString:string];
    
    int intValue;
    BOOL isValid = [scan scanInt:&intValue] && [scan isAtEnd];
    
    if ( isValid && [string intValue] >= 0 ) {
        return YES;
    }
    return NO;
}


/**
 通过自定义规则的key从model中获取value

 @param key jey
 @param model model
 @return 是否成功获取
 */
- (BOOL)targetModelWithKey:(NSString *)key model:(id *)model {
    
    if ( [key hasPrefix:@"["] ) {
        
        if ( key.length <= 1 ) return NO;
        
        if ( ![*model isKindOfClass:NSArray.class] ) return NO;
        
        NSString *indexString = [key substringFromIndex:1];
        if ( ![self isValidInt:indexString] ) {
            return NO;
        }
        
        NSInteger arrayIndex = [indexString intValue];
        NSArray *keyForArrayValue = (NSArray *)*model;
        *model = [keyForArrayValue objectAtIndex:arrayIndex];
        
    }
    /**else if ( [key hasPrefix:@"{"] ) {}**/
    else {
        
        if ( [self isValidInt:key] ) {
            return NO;
        }
        
        *model = [*model valueForKey:key];
    }
    
    return YES;
}

@end
