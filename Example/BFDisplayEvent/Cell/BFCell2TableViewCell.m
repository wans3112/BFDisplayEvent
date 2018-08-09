//
//  BFCell2TableViewCell.m
//  Example
//
//  Created by wans on 2017/5/8.
//  Copyright © 2017年 wans. All rights reserved.
//

#import "BFCell2TableViewCell.h"
#import "UIButton+Block.h"
#import <BFDisplayEvent/BFDisplayEvent.h>
#import <BFDisplayEvent/BFVVMBindingContext.h>

#define keyPath(objc, keyPath) @(((void)objc.keyPath, #keyPath))

@interface BFCell2TableViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *label;

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
    
    NSObject<BFCell2Protocol> *model = theModel.model;
//    NSLog(@"model.title:%@", model.title);
    // 此处传入本为BFModel2，并无title字段，具体参考BFModel2查看
    __weak typeof(self) weakSelf = self;
    [self.button addActionHandler:^(NSInteger tag) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        // 暂不管循环引用
//        UIViewController *vc = [[NSClassFromString(@"MasterViewController") alloc] init];
//        [strongSelf.em_viewController.navigationController pushViewController:vc animated:YES];
//        model.name = @"wb";
        
        [strongSelf.eventManager  em_didSelectItemWithModelBlock:^(BFEventModel *eventModel) {
            eventModel.indexPath = theModel.indexPath;
        }];
    }];
    
    EMObserve(model, name, self.label, text);
//    EMObserve(model, name, self.label, textColor);
    
//    EMVOObserveAction(model, name, ^(NSString *name){
//        [self.button setTitle:name forState:UIControlStateNormal];
//    });

    
//    void (^target)(id target, char *) = ^(id target, char *s){
//
//    };
    
    
    
    
    
//    [model bindingWithPath:@"model.name" action:^{
//        [self.button setTitle:model.name forState:UIControlStateNormal];
//    }];
}

- (void)dealloc {
    
}

@end
