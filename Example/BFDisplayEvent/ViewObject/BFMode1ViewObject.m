//
//  BFMode1ViewObject.m
//  BFDisplayEvent_Example
//
//  Created by wans on 2018/7/13.
//  Copyright © 2018年 wans. All rights reserved.
//

#import "BFMode1ViewObject.h"
#import "BFModel.h"

@implementation BFMode1ViewObject

- (NSString *)title {
    
    return [NSString stringWithFormat:@"第一分批：%@", self.model1.title];
}

- (BFModel *)model1 {
    
    return self.entityModel;
}

- (void)dealloc {
    
}
@end
