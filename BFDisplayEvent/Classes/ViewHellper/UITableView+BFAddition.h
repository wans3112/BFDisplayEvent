//
//  UITableView+BFAddition.h
//  BFDisplayEvent
//
//  Created by wans on 2018/8/10.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (BFAddition)

@property (nonatomic, strong) NSIndexPath *em_indexPath;

@end

@interface UITableView (BFAddition)

- (void)em_registerNib:(nullable UINib *)nib forCellReuseIdentifier:(NSString *)identifier;
- (void)em_registerNib:(nullable UINib *)nib forCellReuseIdentifier:(NSString *)identifier withSection:(NSUInteger)section;
- (void)em_registerNib:(nullable UINib *)nib forCellReuseIdentifier:(NSString *)identifier indexPath:(NSIndexPath *)indexPath;

- (void)em_registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier;
- (void)em_registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier withSection:(NSUInteger)section;
- (void)em_registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier indexPath:(NSIndexPath *)indexPath;

- (__kindof UITableViewCell *)em_dequeueReusableCellOnlySecionWithIndexPath:(NSIndexPath *)indexPath;
- (__kindof UITableViewCell *)em_dequeueReusableCellWithIndexPath:(NSIndexPath *)indexPath;

@end
