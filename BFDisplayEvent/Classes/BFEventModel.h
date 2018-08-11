//
//  BFEventModel.h
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2017/4/11.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BFEventModel : NSObject

@property (nonatomic,strong) id                               model;

@property (nonatomic,strong) NSIndexPath                      *indexPath;

@property (nonatomic,assign) NSInteger                        eventType;

/**
 保留字段
 */
@property (nonatomic,assign) NSString                         *otherType;

@property (nonatomic,strong) id                               target;

@end
