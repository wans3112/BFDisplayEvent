//
//  BFCell1TableViewCell.m
//  Example
//
//  Created by wans on 2017/5/8.
//  Copyright © 2017年 wans. All rights reserved.
//

#import "BFCell1TableViewCell.h"
#import "UIResponder+EventManager.h"
#import <BFDisplayEvent/BFDisplayEvent.h>

@interface BFCell1TableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
@implementation BFCell1TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)em_displayWithModel:(BFEventManagerBlock)eventBlock {

    BFEventModel *theModel = self.em_Model(eventBlock);

    NSObject<BFCell1Protocol> *model = theModel.model;
    self.label.text = model.title;
    
//    [model bindingWithPath:@"model.name"];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self em_SetParamsValue:@"wans" key:@"can"];
}

@end
