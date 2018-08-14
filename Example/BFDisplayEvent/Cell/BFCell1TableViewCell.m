//
//  BFCell1TableViewCell.m
//  Example
//
//  Created by wans on 2017/5/8.
//  Copyright © 2017年 wans. All rights reserved.
//

#import "BFCell1TableViewCell.h"

@interface BFCell1TableViewCell ()<BFDisplayProtocol>
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
@implementation BFCell1TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)em_displayWithModel:(BFEventManagerBlock)eventBlock {

    id<BFCell1Protocol> model = self.em_model(eventBlock).model;

    // view与model绑定
    EMVOObserve(model, title, self, label.text);
}

- (void)dealloc {
    NSLog(@"%@ dealloc", [self class]);
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
