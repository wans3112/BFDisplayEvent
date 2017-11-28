//
//  ExampleManager.m
//  Example
//
//  Created by wans on 2017/5/8.
//  Copyright © 2017年 wans. All rights reserved.
//

#import "ExampleManager.h"

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

- (void)em_didSelectItemWithEventType:(NSInteger)eventType {
    
    switch ( eventType ) {
            case 3:
                NSLog(@"master 3 pressed");
            break;
        default:
            break;
    }
}

@end
