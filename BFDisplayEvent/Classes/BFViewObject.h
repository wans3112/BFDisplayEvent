//
//  BFViewObject.h
//  HomePage https://github.com/wans3112/BFDisplayEvent
//
//  Created by wans on 2018/7/13.
//  Copyright © 2017年 wans,www.wans3112.cn All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFViewObject : NSObject

@property (nonatomic, strong, readonly) id                                   entityModel;

- (instancetype)initWithModel:(id)entityModel;

@end

@interface NSObject (ModelForView)

/**
 通过model生成ViewObject
 
 @param model 数据model
 @return ViewObject
 */
+ (instancetype)em_mfv:(id)model;

@end
