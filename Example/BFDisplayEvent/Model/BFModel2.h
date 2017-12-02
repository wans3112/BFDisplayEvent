//
//  BFModel2.h
//  Example
//
//  Created by wans on 2017/5/8.
//  Copyright © 2017年 wans. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFPropertyExchange.h"
#import "BFModel.h"

@interface BFModel2 : BFPropertyExchange

@property (nonatomic,strong) NSString *name;

@property (nonatomic,strong) BFModel *model;

@end
