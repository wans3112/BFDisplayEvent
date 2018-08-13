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
#import "BFMode2ViewObject.h"
#import "NSObject+BFKeyValue.h"

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
    
    BFEventModel *theModel = self.em_model(eventBlock);
    
    NSLog(@"master %ld pressed", theModel.indexPath.row);

    NSIndexPath *indexPath = theModel.indexPath;
    [self em_handleUpdateTargetWithKeys:@[@"self",@"objects"] eventBlock:^(MasterViewController *vc, NSMutableArray<NSMutableArray *> *objects){
        
        NSMutableArray *temp = objects[indexPath.section];
        BFModel2 *model = temp[indexPath.row];
        model.name = @"wans";
        
//        NSString *path = [NSString stringWithFormat:@"objects.[%ld.[%ld.model.name", indexPath.section, indexPath.row];
//        id objc =  [self.em_viewController em_valueForKeyPath:@"objects.[1.[1"];
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
