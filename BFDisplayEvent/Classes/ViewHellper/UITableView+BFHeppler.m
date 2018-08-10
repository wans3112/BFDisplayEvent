//
//  UITableView+BFHelpper.m
//  BFDisplayEvent
//
//  Created by wans on 2018/8/10.
//

#import "UITableView+BFHelpper.h"
#import "objc/runtime.h"

static void *kPropertyBindingManagerKey = &kPropertyBindingManagerKey;
static NSString *kCommonIdentifierKey   = @"CommonIdentifierKey";

@implementation UITableView (BFHelpper)

- (void)updateIdentifierManager:(NSString *)identifier identifierKey:(NSString *)identifierKey {
    
    NSMutableDictionary *tempDic = self.identifierManager;
    if ( !tempDic ) {
        tempDic = @{}.mutableCopy;
    }
    tempDic[identifierKey] = identifier;
    
    self.identifierManager = tempDic;
    
}

- (void)em_registerNib:(nullable UINib *)nib forCellReuseIdentifier:(NSString *)identifier {
    
    if ( !identifier || !nib ) {
        return;
    }
    
    [self updateIdentifierManager:identifier identifierKey:kCommonIdentifierKey];
    
    [self registerNib:nib forCellReuseIdentifier:identifier];
}

- (void)em_registerNib:(nullable UINib *)nib forCellReuseIdentifier:(NSString *)identifier withSection:(NSUInteger)section {
    
    if ( !identifier || !nib ) {
        return;
    }
    
    NSString *identifierKey = [NSString stringWithFormat:@"%ld-0", section];
    
    [self updateIdentifierManager:identifier identifierKey:identifierKey];

    [self registerNib:nib forCellReuseIdentifier:identifier];
}

- (void)em_registerNib:(nullable UINib *)nib forCellReuseIdentifier:(NSString *)identifier indexPath:(NSIndexPath *)indexPath {
    
    if ( !identifier || !nib || !indexPath ) {
        return;
    }
    
    NSString *identifierKey = [NSString stringWithFormat:@"%ld-%ld",indexPath.section, indexPath.row];
    
    [self updateIdentifierManager:identifier identifierKey:identifierKey];
    
    [self registerNib:nib forCellReuseIdentifier:identifier];
}

- (void)em_registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    
    if ( !identifier || !cellClass ) {
        return;
    }
    
    [self updateIdentifierManager:identifier identifierKey:kCommonIdentifierKey];
    
    [self registerClass:cellClass forCellReuseIdentifier:identifier];
}

- (void)em_registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier withSection:(NSUInteger)section {
    
    if ( !identifier || !cellClass ) {
        return;
    }
    
    NSString *identifierKey = [NSString stringWithFormat:@"%ld-0", section];
    
    [self updateIdentifierManager:identifier identifierKey:identifierKey];
    
    [self registerClass:cellClass forCellReuseIdentifier:identifier];
}

- (void)em_registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier indexPath:(NSIndexPath *)indexPath {
    
    if ( !identifier || !cellClass || !indexPath ) {
        return;
    }
    
    NSString *identifierKey = [NSString stringWithFormat:@"%ld-%ld",indexPath.section, indexPath.row];
    
    [self updateIdentifierManager:identifier identifierKey:identifierKey];
    
    [self registerClass:cellClass forCellReuseIdentifier:identifier];
}

- (__kindof UITableViewCell *)em_dequeueReusableCellOnlySecionWithIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifierKey = [NSString stringWithFormat:@"%ld-0", indexPath.section];
    NSString *identifier = self.identifierManager[identifierKey];
    if ( !identifier ) {
        identifier = self.identifierManager[kCommonIdentifierKey];
    }
    
    return [self dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
}

- (__kindof UITableViewCell *)em_dequeueReusableCellWithIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifierKey = [NSString stringWithFormat:@"%ld-%ld",indexPath.section, indexPath.row];
    NSString *identifier = self.identifierManager[identifierKey];
    if ( !identifier ) {
        identifier = self.identifierManager[kCommonIdentifierKey];
    }
    
    return [self dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
}

#pragma mark - Getter&&Setter

- (void)setIdentifierManager:(NSMutableDictionary *)identifierManager {
    objc_setAssociatedObject(self, kPropertyBindingManagerKey, identifierManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)identifierManager {
    return objc_getAssociatedObject(self, kPropertyBindingManagerKey);
}

@end
