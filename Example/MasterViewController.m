//
//  MasterViewController.m
//  Example
//
//  Created by wans on 2017/5/8.
//  Copyright © 2017年 wans. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "BFCell1TableViewCell.h"
#import "BFModel.h"
#import "BFModel2.h"
#import "BFDisplayEventProtocol.h"
#import "ExampleManager.h"

@interface MasterViewController ()

@property NSMutableArray *objects;
@property (nonatomic,strong) ExampleManager *eventManager;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
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
                [tempArr addObject:model];
            }
            [self.objects addObject:tempArr];
            
        }
       
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BFCell1TableViewCell" bundle:nil] forCellReuseIdentifier:@"BFCell1TableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BFCell2TableViewCell" bundle:nil] forCellReuseIdentifier:@"BFCell2TableViewCell"];

    self.tableView.estimatedRowHeight = 44;
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
        eventModel.eventType = indexPath.section;//测试，区分不同section的事件是不同的(此处可能是另一个界面共用此cell，需要新建一个eventManager)
    }];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (ExampleManager *)eventManager {
    if( !_eventManager ) {
        _eventManager = [[ExampleManager alloc] initWithTarget:self];
    }
    return _eventManager;
}
@end
