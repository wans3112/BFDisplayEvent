//
//  BFCell2TableViewCell.h
//  Example
//
//  Created by wans on 2017/5/8.
//  Copyright © 2017年 wans. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BFCell2Protocol <NSObject>

@property (nonatomic, weak, readonly) id                                   model;

@property (nonatomic,strong) NSString *name;

@property (nonatomic,strong) NSString *title;

@end

@interface BFCell2TableViewCell : UITableViewCell

@end
