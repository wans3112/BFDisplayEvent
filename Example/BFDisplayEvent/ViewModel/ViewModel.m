//
//  ViewModel.m
//  WBDisplayEvent_Example
//
//  Created by 王斌(平安科技智慧教育团队项目研发部知鸟研发团队移动开发组) on 2018/8/11.
//  Copyright © 2018年 wans. All rights reserved.
//

#import "ViewModel.h"
#import "BFModel.h"
#import "BFModel2.h"
#import "BFMode1ViewObject.h"
#import "BFMode2ViewObject.h"

@implementation ViewModel

+ (NSMutableArray *)doGetDataSources {
    
    NSMutableArray *dataSources = [@[] mutableCopy];
    for (int i = 0; i < 3; i++) {
        
        if ( i == 0 ) {
            NSMutableArray *tempArr = [@[] mutableCopy];
            for (int i = 0; i < 3; i++) {
                BFModel *model = [[BFModel alloc] init];
                model.title = [NSString stringWithFormat:@"index %d",i + 1];
                [tempArr addObject:[[BFMode1ViewObject alloc] initWithModel:model]];
            }
            [dataSources addObject:tempArr];
            
        }else {
            
            NSMutableArray *tempArr = [@[] mutableCopy];
            for (int i = 0; i < 5; i++) {
                BFModel2 *model = [[BFModel2 alloc] init];
                model.name = [NSString stringWithFormat:@"button %lu／%d",(unsigned long)dataSources.count, i + 1];
                
                BFModel *model_ = [[BFModel alloc] init];
                model_.title = [NSString stringWithFormat:@"index %d",i + 1];
                model.model = model_;
                
                [tempArr addObject:model];
            }
            
            tempArr = [BFMode2ViewObject em_objectArrayWithViewObjectArray:tempArr];
            [dataSources addObject:tempArr];
            
        }
    }
    
    return dataSources;
}

@end
