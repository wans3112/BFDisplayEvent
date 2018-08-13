//
//  NSObject+BFMVVMBinding.h
//  BFDisplayEvent
//
//  Created by wans on 2018/6/27.
//

#import <Foundation/Foundation.h>

/**
 添加绑定监听

 @param MODEL 监听数据源
 @param MODELPATH 需要监听的数据源字段
 @param TARGET 需要更新的对象
 @param TARGETPATH 需要更新对象字段
 @return 无
 */
#define EMVOObserve(MODEL, MODELPATH, TARGET, TARGETPATH) \
em_observervoPath(MODEL, @(((void)MODEL.MODELPATH, #MODELPATH)), TARGET, @(((void)TARGET.TARGETPATH, #TARGETPATH)))

#define EMObserve(MODEL, MODELPATH, TARGET, TARGETPATH) \
em_observerPath(MODEL, @(((void)MODEL.MODELPATH, #MODELPATH)), TARGET, @(((void)TARGET.TARGETPATH, #TARGETPATH)))

#define EMObserveAction(MODEL, MODELPATH, ACTION) \
em_observerPathAction(MODEL, @(((void)MODEL.MODELPATH, #MODELPATH)), ACTION)

#define EMVOObserveAction(MODEL, MODELPATH, ACTION) \
em_observervoPathAction(MODEL, @(((void)MODEL.MODELPATH, #MODELPATH)), ACTION)

@interface NSObject (BFMVVMBinding)

@property (nonatomic, copy) NSMutableDictionary *bindingManager;

void em_observerPath(id model, NSString *observerPath, id target, NSString *targetPath);
void em_observervoPath(id model, NSString *observerPath, id target, NSString *targetPath);

void em_observerPathAction(id model, NSString *observerPath, id targetAction);
void em_observervoPathAction(id model, NSString *observerPath, id targetAction);



@end
