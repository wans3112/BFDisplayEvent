//
//  BFMode2ViewObject.m
//  BFDisplayEvent_Example
//
//  Created by wans on 2018/7/13.
//  Copyright © 2018年 wans. All rights reserved.
//

#import "BFMode2ViewObject.h"

@implementation BFMode2ViewObject

- (NSString *)name {

    return [NSString stringWithFormat:@"自定义：%@", self.model2.name];
}

- (NSString *)title {
    
    return @"超级按钮";
}

- (BFModel2 *)model2 {
    
    return self.entityModel;
}

- (void)dealloc {
    
}
@end
