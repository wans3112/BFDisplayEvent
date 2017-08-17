//
//  BFEventModel.h
//  Pods
//
//  Created by wans on 2017/4/11.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BFEventModel : NSObject

@property (nonatomic,strong) id                               model;

@property (nonatomic,strong) NSIndexPath                      *indexPath;

@property (nonatomic,assign) NSInteger                        eventType;

/**
 保留字段
 */
@property (nonatomic,assign) NSString                         *otherType;

@property (nonatomic,strong) UIView                           *targetView;

@end
