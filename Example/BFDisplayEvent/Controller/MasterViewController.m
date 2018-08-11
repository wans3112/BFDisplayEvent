//
//  MasterViewController.m
//  Example
//
//  Created by wans on 2017/5/8.
//  Copyright © 2017年 wans. All rights reserved.
//

#import "MasterViewController.h"
#import "ViewModel.h"

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
    self.objects = [ViewModel doGetDataSources];
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
