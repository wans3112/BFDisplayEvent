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

@property (nonatomic,strong) id                               model;       //!< 数据模型

@property (nonatomic,strong) NSIndexPath                      *indexPath;  //!< 序号

@property (nonatomic,assign) NSInteger                        eventType;   //!< 事件类型

@property (nonatomic,assign) NSString                         *identifier; //!< 事件标识

@property (nonatomic,strong) id                               target;      //!< target

@end
