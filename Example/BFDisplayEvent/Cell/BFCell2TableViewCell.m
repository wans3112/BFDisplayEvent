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

    __weak typeof(self) weakSelf = self;

    // view与model绑定
    EMVOObserve(model, name, self.label, text);
    EMVOObserveAction(model, title, ^(NSString *titleValue){
        [self.button setTitle:titleValue forState:UIControlStateNormal];
    });

    // btn事件处理
    [self.button addActionHandler:^(NSInteger tag) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        // 回调给target,这里的target就是vc
        void(^countBlock)(int) = strongSelf.em_paramForKey(@"key");
        if(countBlock) countBlock((int)strongSelf.em_indexPath.row);
        
        
         // 也可以交给事件管理器触发事件
         /**
          [strongSelf.eventManager  em_didSelectItemWithModelBlock:^(BFEventModel *eventModel) {
              eventModel.indexPath = self.indexPath;
              eventModel.identifier = @"from BFCell2TableViewCell";
          }];
          **/
         
    }];
    
}

- (void)dealloc {
    NSLog(@"%@ dealloc", [self class]);
}

@end
