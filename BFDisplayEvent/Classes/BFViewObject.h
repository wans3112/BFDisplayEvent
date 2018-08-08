//
//  BFViewObject.h
//  BFDisplayEvent
//
//  Created by wans on 2018/7/13.
//

#import <Foundation/Foundation.h>

@interface BFViewObject : NSObject

@property (nonatomic, weak, readonly) id                                   model;

- (instancetype)initWithModel:(id)model;

@end

@interface NSObject (ModelForView)

+ (instancetype)em_mfv:(id)model;

@end
