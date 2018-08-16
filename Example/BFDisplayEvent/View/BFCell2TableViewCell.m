//
//  BFCell2TableViewCell.m
//  Example
//
//  Created by wans on 2017/5/8.
//  Copyright © 2017年 wans. All rights reserved.
//

#import "BFCell2TableViewCell.h"


@interface BFCell2TableViewCell ()<BFDisplayProtocol>
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation BFCell2TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)em_displayWithModel:(BFEventManagerBlock)eventBlock {
    
    NSObject<BFCell2Protocol> *model = self.em_model(eventBlock).model;

    // view与model绑定
    EMVOObserve(model, name, self.label, text);
    EMVOObserveAction(model, title, ^(NSString *titleValue){
        [self.button setTitle:titleValue forState:UIControlStateNormal];
    });

    // btn事件处理
    [self.button addActionHandler:^(NSInteger tag) {
        model.name = @"wans";
    }];
}

- (IBAction)btnPressed:(id)sender {
    
    NSObject<BFCell2Protocol> *model = self.eventModel.model;
    model.name = @"wans";

}

- (void)dealloc {
    NSLog(@"%@ dealloc", [self class]);
}

@end
