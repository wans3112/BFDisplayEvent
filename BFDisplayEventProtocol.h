//
//  BFDisplayEventProtocol.h
//  Pods
//
//  Created by wans on 2017/4/12.
//
//

#ifndef BFDisplayEventProtocol_h
#define BFDisplayEventProtocol_h

/**
 参数传递block

 @param model 参数model
 */
typedef void (^BFEventManagerBlock)(BFEventModel* eventModel);
typedef void (^BFEventManagerDoneBlock)();


/**
 显示数据协议
 */
@protocol BFDisplayProtocol <NSObject>

- (void)displayWithModel:(BFEventManagerBlock)eventBlock;

@end



/**
 点击事件协议
 */
@protocol BFEventManagerProtocol <NSObject>

- (void)didSelectItemWithModel:(BFEventModel *)eventModel;

- (void)didSelectItemWithModelBlock:(BFEventManagerBlock)eventBlock;

@required
- (NSString *)eventManagerWithPropertName;

@end

#endif /* BFDisplayEventProtocol_h */
