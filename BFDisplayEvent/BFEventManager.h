//
//  BFEventManager.h
//  Pods
//
//  Created by wans on 2017/4/10.
//
//

#import <Foundation/Foundation.h>
#import "BFEventModel.h"
#import "BFDisplayEventProtocol.h"

typedef id (^BFSetValueForKeyBlock)(NSString *key);

/**
 默认调用，按vc区分
 */
#define EventInvocationDefault \
if ( [self respondsToSelector:@selector(em_CommonEvents:)]) [self em_CommonEvents:eventModel]; \
NSString *selName = [NSString stringWithFormat:@"em_%@:", NSStringFromClass(self.em_viewController.class)]; \
SEL vcSel = NSSelectorFromString(selName); \
if ( [self respondsToSelector:vcSel]) { \
    [self performSelector:vcSel withObject:eventModel]; \
    return; \
}


typedef BFEventModel* (^BFEventModelBlock)(BFEventManagerBlock eventBlock);

@interface BFEventManager : NSObject<BFEventManagerProtocol>

/**
 通过kvc获取controller的属性
 */
@property (nonatomic, copy)   BFSetValueForKeyBlock                    em_ValueForKey;

/**
 快捷转换
 */
@property (nonatomic, strong) BFEventModelBlock                        em_Model;

/**
 targetView所属的controller
 */
@property (nonatomic, weak)   UIViewController                         *em_viewController;

- (instancetype)initWithTarget:(UIView *)targetView;

/**
 获取实例
 
 @param instance 实例block
 @return EventModel实例
 */
- (id)em_Setup:instance block:(BFEventManagerBlock) block;


/**
 将model转化为block

 @param model eventmodel
 @return block
 */
- (BFEventManagerBlock)em_Block:(BFEventModel *)model;


/**
 简单跳转

 @param eventType 事件标志
 */
- (void)em_didSelectItemWithEventType:(NSInteger)eventType;


- (void)em_CommonEvents:(BFEventModel *)eventModel;

/**
 通过kvc赋值
 
 @param value 新值
 @param key
 */
- (void)em_SetValue:(id)value key:(NSString *)key;

@end
