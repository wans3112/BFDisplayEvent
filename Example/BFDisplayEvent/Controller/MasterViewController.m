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
#import <BFDisplayEvent/BFDisplayEvent.h>
#import <CTObjectiveCRuntimeAdditions/CTBlockDescription.h>

@interface MasterViewController ()

@property (nonatomic, strong) NSMutableArray *objects;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.objects = [@[] mutableCopy];
    for (int i = 0; i < 3; i++) {
        
        if ( i == 0 ) {
            NSMutableArray *tempArr = [@[] mutableCopy];
            for (int i = 0; i < 3; i++) {
                BFModel *model = [[BFModel alloc] init];
                model.title = [NSString stringWithFormat:@"index %d",i + 1];
                [tempArr addObject:model];
            }
            [self.objects addObject:tempArr];
            
        }else {
            
            NSMutableArray *tempArr = [@[] mutableCopy];
            for (int i = 0; i < 2; i++) {
                BFModel2 *model = [[BFModel2 alloc] init];
                model.name = [NSString stringWithFormat:@"button %lu／%d",(unsigned long)self.objects.count, i + 1];
                
                BFModel *model_ = [[BFModel alloc] init];
                model_.title = [NSString stringWithFormat:@"index %d",i + 1];
                model.model = model_;
                
                [tempArr addObject:model];
            }
            [self.objects addObject:tempArr];
            
        }
       
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BFCell1TableViewCell" bundle:nil] forCellReuseIdentifier:@"BFCell1TableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BFCell2TableViewCell" bundle:nil] forCellReuseIdentifier:@"BFCell2TableViewCell"];

    self.tableView.estimatedRowHeight = 44;
    
    // 注册事件管理器
    [self em_RegisterWithClassName:@"ExampleManager"];

}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.objects.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSMutableArray *)self.objects[section]).count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell<BFDisplayProtocol> *cell = [tableView dequeueReusableCellWithIdentifier:!indexPath.section ? @"BFCell1TableViewCell" : @"BFCell2TableViewCell"];

    id object = ((NSMutableArray *)self.objects[indexPath.section])[indexPath.row];
    [cell em_displayWithModel:^(BFEventModel *eventModel) {
        eventModel.model = object;
        eventModel.eventType = indexPath.section;//测试，区分不同section的事件是不同的(此处如果是另一个界面共用此cell，需要新建一个eventManager)
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    NSString *vlue = self.em_ParamForKey(@"can");
//    NSLog(@"%@", vlue);
    
    if ( indexPath.section == 1 ) {
        [self.eventManager  em_didSelectItemWithModelBlock:^(BFEventModel *eventModel) {
            eventModel.indexPath = indexPath;
        }];
    }

}

@end
