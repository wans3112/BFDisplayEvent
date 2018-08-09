//
//  BFVVMBindingContext.m
//  BFDisplayEvent
//
//  Created by wans on 2018/6/27.
//

#import "BFVVMBindingContext.h"
#import "objc/runtime.h"
#import "objc/message.h"

static void *kPropertyBindingManagerKey = &kPropertyBindingManagerKey;

@implementation NSObject (BFVVMBindingContext)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
- (void)em_observerPath:(NSString *)observerPath targetAction:(void(^)())targetAction {
#pragma clang diagnostic pop

    if ( !observerPath ) return;
    
    __weak typeof(self) weakSelf = self;
    [self addObserver:self forKeyPath:observerPath options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    
    if ( !self.bindingManager ) {
        self.bindingManager = @{}.mutableCopy;
    }
    
    NSString *keyPath = observerPath;
    if ( [keyPath containsString:@"."] ) {
        keyPath = [keyPath componentsSeparatedByString:@"."].lastObject;
    }
    
    void(^updateAction)(void) = ^(){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ( targetAction ){
            id newValue = [strongSelf valueForKeyPath:keyPath];
            targetAction(newValue);
        }
    };
    
    updateAction();
    
    NSMutableDictionary *manager = self.bindingManager;
    manager[observerPath] = updateAction;
    self.bindingManager = manager;
}

- (void)em_observerPath:(NSString *)observerPath target:(id)target targetPath:(NSString *)targetPath {
    
    if ( !observerPath ) return;
    
    __weak typeof(self) weakSelf = self;
    [self addObserver:self forKeyPath:observerPath options:NSKeyValueObservingOptionNew context:(__bridge void *)self];
    
    if ( !self.bindingManager ) {
        self.bindingManager = @{}.mutableCopy;
    }
    
    NSString *keyPath = observerPath;
    if ( [keyPath containsString:@"."] ) {
        keyPath = [keyPath componentsSeparatedByString:@"."].lastObject;
    }
    
    void(^updateAction)(void) = ^(){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [target setValue:[strongSelf valueForKeyPath:keyPath] forKeyPath:targetPath];
    };
    
    // 第一次默认赋值
    updateAction();
    
    NSMutableDictionary *manager = self.bindingManager;
    manager[observerPath] = updateAction;
    self.bindingManager = manager;
}

void em_observerPath(id model, NSString *observerPath, id target, NSString *targetPath) {
    
    ((void (*)(id, SEL, NSString *, id, NSString *))objc_msgSend)(model, @selector(em_observerPath:target:targetPath:), observerPath, target, targetPath);
}

void em_observervoPath(id model, NSString *observerPath, id target, NSString *targetPath) {
    
    ((void (*)(id, SEL, NSString *, id, NSString *))objc_msgSend)(model, @selector(em_observervoPath:target:targetPath:), observerPath, target, targetPath);
}

- (void)em_observervoPath:(NSString *)observerPath target:(id)target targetPath:(NSString *)targetPath {
    
    NSString *observerPath2 = [@"model." stringByAppendingString:observerPath];
    [self em_observerPath:observerPath2 target:target targetPath:targetPath];
}

void em_observerPathAction(id model, NSString *observerPath, id targetAction) {
    
    ((void (*)(id, SEL, NSString *, id))objc_msgSend)(model, @selector(em_observerPath:targetAction:), observerPath, targetAction);
}

void em_observervoPathAction(id model, NSString *observerPath, id targetAction) {
    
    NSString *observerPath2 = [@"model." stringByAppendingString:observerPath];
    
    ((void (*)(id, SEL, NSString *, id))objc_msgSend)(model, @selector(em_observerPath:targetAction:), observerPath2, targetAction);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    NSLog(@"path:%@", keyPath);

    if ( [self.bindingManager.allKeys containsObject:keyPath] ) {
        void(^updateAction)(void) = self.bindingManager[keyPath];
        if ( updateAction ) {
            updateAction();
        }
    }
}

#pragma mark - Getter&&Setter

- (void)setBindingManager:(NSMutableDictionary *)bindingManager {
    objc_setAssociatedObject(self, kPropertyBindingManagerKey, bindingManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)bindingManager {
    return objc_getAssociatedObject(self, kPropertyBindingManagerKey);
}

#pragma mark - Swizzle

+ (void)load {
    Method method1 = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
    Method method2 = class_getInstanceMethod([self class], @selector(deallocSwizzle));
    method_exchangeImplementations(method1, method2);
}

- (void)deallocSwizzle {
    
    // 销毁时移除所有监听
    if ( self.bindingManager ) {
        __weak typeof(self) weakSelf = self;
        [self.bindingManager enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf removeObserver:self forKeyPath:key context:(__bridge void *)self];
            [strongSelf.bindingManager removeObjectForKey:key];
        }];
        self.bindingManager = nil;
    }

    [self deallocSwizzle];
}

@end
