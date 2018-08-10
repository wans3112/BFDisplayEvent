//
//  MasterViewController.m
//  Example
//
//  Created by wans on 2017/5/8.
//  Copyright © 2017年 wans. All rights reserved.
//

#import "MasterViewController.h"
#import "BFModel.h"
#import "BFModel2.h"
#import "BFMode2ViewObject.h"
#import "BFMode1ViewObject.h"

@interface MasterViewController ()

@property (nonatomic, strong) NSMutableArray *objects;

@end

@implementation MasterViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    [self createDataSource];
}

/**
 *  构建视图
 */
- (void)createUI {
    
    // 注册cell
    [self.tableView em_registerNib:[UINib nibWithNibName:@"BFCell1TableViewCell" bundle:nil]
            forCellReuseIdentifier:@"BFCell1TableViewCell"
                       withSection:0];
    [self.tableView em_registerNib:[UINib nibWithNibName:@"BFCell2TableViewCell" bundle:nil]
            forCellReuseIdentifier:@"BFCell2TableViewCell"];
    
    self.tableView.estimatedRowHeight = 44;
    
    // 注册事件管理器
    [self em_RegisterWithClassName:@"ExampleManager"];
}

/**
 *  构建数据
 */
- (void)createDataSource {
  
    self.objects = [@[] mutableCopy];
    for (int i = 0; i < 3; i++) {
        
        if ( i == 0 ) {
            NSMutableArray *tempArr = [@[] mutableCopy];
            for (int i = 0; i < 3; i++) {
                BFModel *model = [[BFModel alloc] init];
                model.title = [NSString stringWithFormat:@"index %d",i + 1];
                [tempArr addObject:[[BFMode1ViewObject alloc] initWithModel:model]];
            }
            [self.objects addObject:tempArr];
            
        }else {
            
            NSMutableArray *tempArr = [@[] mutableCopy];
            for (int i = 0; i < 5; i++) {
                BFModel2 *model = [[BFModel2 alloc] init];
                model.name = [NSString stringWithFormat:@"button %lu／%d",(unsigned long)self.objects.count, i + 1];
                
                BFModel *model_ = [[BFModel alloc] init];
                model_.title = [NSString stringWithFormat:@"index %d",i + 1];
                model.model = model_;
                
                [tempArr addObject:[BFMode2ViewObject em_mfv:model]];
            }
            [self.objects addObject:tempArr];
            
        }
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.objects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSMutableArray *)self.objects[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell<BFDisplayProtocol> *cell = [tableView em_dequeueReusableCellOnlySecionWithIndexPath:indexPath];

    id object = ((NSMutableArray *)self.objects[indexPath.section])[indexPath.row];
    [cell em_displayWithModel:^(BFEventModel *eventModel) {
        eventModel.model = object;
        eventModel.indexPath = indexPath;
        eventModel.eventType = indexPath.section;//测试，区分不同section的事件是不同的(此处如果是另一个界面共用此cell，需要新建一个eventManager)
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ( indexPath.section == 1 ) {
        [self.eventManager  em_didSelectItemWithModelBlock:^(BFEventModel *eventModel) {
            eventModel.indexPath = indexPath;
        }];
    }

}

- (void)dealloc {
    NSLog(@"%@ dealloc", [self class]);
}

@end
