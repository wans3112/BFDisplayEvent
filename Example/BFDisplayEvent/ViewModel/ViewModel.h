//
//  ViewModel.h
//  WBDisplayEvent_Example
//
//  Created by 王斌(平安科技智慧教育团队项目研发部知鸟研发团队移动开发组) on 2018/8/11.
//  Copyright © 2018年 wans. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewModel : NSObject

+ (NSMutableArray *)doGetDataSources;

+ (void)doGetDataSourcesWithCompletion:(void(^)(id))completion;

@end
