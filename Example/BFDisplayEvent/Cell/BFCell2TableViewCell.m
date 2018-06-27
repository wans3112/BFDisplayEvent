//
//  BFCell2TableViewCell.m
//  Example
//
//  Created by wans on 2017/5/8.
//  Copyright © 2017年 wans. All rights reserved.
//

#import "BFCell2TableViewCell.h"
#import "BFModel.h"
#import "UIButton+Block.h"
#import <BFDisplayEvent/BFDisplayEvent.h>

@interface BFCell2TableViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation BFCell2TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonPressed:(id)sender {
    
}

- (void)em_displayWithModel:(BFEventManagerBlock)eventBlock {
    
    BFEventModel *theModel = self.em_Model(eventBlock);
    
    BFModel *model = theModel.model;
//    NSLog(@"model.title:%@", model.title);
    // 此处传入本为BFModel2，并无title字段，具体参考BFModel2查看
    [self.button setTitle:model.title forState:UIControlStateNormal];
//    [self.button addActionHandler:^(NSInteger tag) {
//        // 暂不管循环引用
//        [self.eventManager em_didSelectItemWithModel:theModel];
//    }];
}

@end
