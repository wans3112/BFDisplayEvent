//
//  ExampleManager.m
//  Example
//
//  Created by wans on 2017/5/8.
//  Copyright © 2017年 wans. All rights reserved.
//

#import "ExampleManager.h"
#import <BFDisplayEvent/BFDisplayEvent.h>
#import "MasterViewController.h"
#import "BFModel2.h"

@implementation ExampleManager

- (void)em_didSelectItemWithModel:(BFEventModel *)eventModel {

    switch ( eventModel.eventType ) {
        case 1:
            NSLog(@"section 1 pressed");
            break;
        case 2:
            NSLog(@"section 2 pressed");
            break;
        case 3:
            NSLog(@"master 3 pressed");
            break;
        default:
            break;
    }
}

- (void)em_didSelectItemWithModelBlock:(BFEventManagerBlock)eventBlock {
    
    BFEventModel *theModel = self.em_Model(eventBlock);
    
    NSLog(@"master %ld pressed", theModel.indexPath.row);

    NSIndexPath *indexPath = theModel.indexPath;
    [self em_handleUpdateTargetWithKeys:@[@"self",@"objects"] eventBlock:^(MasterViewController *vc, NSMutableArray<NSMutableArray *> *objects){
        
        NSMutableArray *temp = objects[indexPath.section];
        
        BFModel2 *model = temp[indexPath.row];
        model.name = @"wans";
        [temp replaceObjectAtIndex:indexPath.row withObject:model];
        [objects replaceObjectAtIndex:indexPath.section withObject:temp];
        
        [vc.tableView reloadData];
        NSLog(@"vc:%@\nobject:%@",vc, objects);
    }];
}

- (void)em_didSelectItemWithEventType:(NSInteger)eventType {
    
    switch ( eventType ) {
            case 3:
        {
            NSLog(@"master 3 pressed");
            
            
        }
            
            break;
        default:
            break;
    }
}

@end
