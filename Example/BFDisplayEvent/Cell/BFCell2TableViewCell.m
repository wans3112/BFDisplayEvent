//
//  BFCell2TableViewCell.m
//  Example
//
//  Created by wans on 2017/5/8.
//  Copyright © 2017年 wans. All rights reserved.
//

#import "BFCell2TableViewCell.h"

@interface BFCell2TableViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation BFCell2TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)em_displayWithModel:(BFEventManagerBlock)eventBlock {
    
    BFEventModel *theModel = self.em_Model(eventBlock);
    NSObject<BFCell2Protocol> *model = theModel.model;
    
    // view与model绑定
    EMVOObserve(model, name, self.label, text);

    // btn事件处理
    __weak typeof(self) weakSelf = self;
    [self.button addActionHandler:^(NSInteger tag) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf.eventManager  em_didSelectItemWithModelBlock:^(BFEventModel *eventModel) {
            eventModel.indexPath = theModel.indexPath;
        }];
    }];
    
}

- (void)dealloc {
    NSLog(@"%@ dealloc", [self class]);
}

@end
