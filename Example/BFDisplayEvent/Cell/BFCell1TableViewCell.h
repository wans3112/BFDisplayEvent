//
//  BFCell1TableViewCell.h
//  Example
//
//  Created by wans on 2017/5/8.
//  Copyright © 2017年 wans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFDisplayEventProtocol.h"

@protocol BFCell1Protocol <NSObject>

@property (nonatomic,strong) NSString *title;

@end


@interface BFCell1TableViewCell : UITableViewCell<BFDisplayProtocol>

@end
