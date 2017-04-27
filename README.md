#####问题描述
在开发应用时，经常遇到一个列表多种不同样式的cell展示的情况，如图：

![WX20170426-182305@2x.png](http://upload-images.jianshu.io/upload_images/5641702-5e5db147fe1f2b2a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

多种cell就会造成cellForRowAtIndexPath（tableview）大量的if ／else，如果再加上显示数据和事件处理简直是灾难，而且不利于以后的扩展，难以维护。

#####解决方案
1.定义一个协议
```
/**
 显示数据协议
 */
@protocol BFDisplayProtocol <NSObject>
- (void)em_displayWithModel:(BFEventModel *)model;
@end
```
2.cell中实现BFDisplayProtocol协议
```

#pragma mark - BFDisplayProtocol

- (void)em_displayWithModel:(CircleItem *)model {
    self.titleLabel.text = model.circleName;
    self.distanceLabel.text = [NSString stringWithFormat:@"%ldm",model.distance];
}
```
>此处cell无需将子view属性暴露出来。

3.在CollectionView/TableView代理中调用显示数据方法
```
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BFDCardNode *model = self.dataSources[indexPath.section];
    UICollectionViewCell<BFDisplayProtocol> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kIdentifier forIndexPath:indexPath];
    [cell em_displayWithModel:model];
    return cell;
}
```
如此，产品经理说列表再加一种cell，你就只需要创建新的cell，然后实现BFDisplayProtocol协议就行了，甚至CollectionView/TableView代理都不需要修改。这样做的好处就是减少cell对controller的依赖，将controller中的逻辑分散道每个cell中自己实现，减少view对controller的耦合。最后代理方法cellForItemAtIndexPath看上去非常整洁舒服😌。

现在问题来了😂，2.中cell对model是有依赖的，也就是说有另一个列表也需要用到这个cell，而且model不同，就无法重用此cell了。现在要做的是解除cell对model的依赖，这时也可以用上面协议的方法实现，就是为model的每一个属性生成一个get方法的协议集合，然后所有的model实现这一个协议，在model中实现协议的方法返回数据。这种情况当model字段少时可以一试，但是当model属性很多时，就会出发大量的协议方法，而且有新的cell共用又要新建大量的共用协议。所以实现协议不能很好的解决cell对model的依赖问题。

#####问题描述
解决cell对model的依赖

#####解决方案
既然协议不能很好的解决该问题，那么我们就曲线救国，有一种轻量的解决办法，就是利用消息转发实现。

1.定义一个model基类BFPropertyExchange
```
@interface BFPropertyExchange : NSObject
- (NSDictionary *)em_exchangeKeyFromPropertyName;
@end
```
2.model实现em_exchangeKeyFromPropertyName方法
```
- (NSDictionary *)em_exchangeKeyFromPropertyName {
    return @{@"name2":@"name",@"icon1":@"icon",@"iconUnselect1":@"iconUnselect"};
}
```
>返回字典代表调用属性与本地属性的映射关系，cell的调用属性是name2，此时传入另一个modelA,但是modelA并没有name2属性，则通过映射关系自动调用本地属性name。

3.消息转发（最重要的一步）
```
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return nil;
}

/**
 消息转发
 
 @param aSelector 方法
 @return 调用方法的描述
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    
    NSString *propertyName = NSStringFromSelector(aSelector);
    
    NSDictionary *propertyDic = [self em_exchangeKeyFromPropertyName];
    
    NSMethodSignature* (^doGetMethodSignature)(NSString *propertyName) = ^(NSString *propertyName){
    
        NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:"v@:"];
        objc_setAssociatedObject(methodSignature, kPropertyNameKey, propertyName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        return  [NSMethodSignature signatureWithObjCTypes:"v@:"];
    };
    
    if ( [propertyDic.allKeys containsObject:propertyName] ) {
        
        NSString *targetPropertyName = [NSString stringWithFormat:@"em_%@",propertyName];
        if ( ![self respondsToSelector:NSSelectorFromString(targetPropertyName)] ) {
            // 如果没有em_重写属性，则用model原属性替换
            targetPropertyName = [propertyDic objectForKey:propertyName];
        }
        
        return doGetMethodSignature(targetPropertyName);
    }
    
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    
    NSString *originalPropertyName = objc_getAssociatedObject(anInvocation.methodSignature, kPropertyNameKey);
    
    if ( originalPropertyName ) {
        anInvocation.selector = NSSelectorFromString(originalPropertyName);
        [anInvocation invokeWithTarget:self];
    }
    
}
```

>此处走的是最后一步的**完全消息转发**，不熟悉消息转发的同学，我找了一个帖子可以看一下：[消息转发](http://www.jianshu.com/p/367b2f6b461f)

4.cell中调用
- 为了方便调用，此处给model写了一个类别。

```
@interface NSObject (PropertyExchange)

/**
 调用替换属性 Invocation property
 */
@property (nonatomic, copy) id(^em_property)(NSString *propertyName);

@end

@implementation NSObject (PropertyExchange)

#pragma mark - Getter&&Setter

- (id(^)(NSString *))em_property {
    
    __weak typeof(self) weakSelf = self;
    id (^icp_block)(NSString *propertyName) = ^id (NSString *propertyName) {
        __strong typeof(self) strongSelf = weakSelf;
        
        SEL sel = NSSelectorFromString(propertyName);
        if ( !sel ) return nil;
        SuppressPerformSelectorLeakWarning(
                                           return [strongSelf performSelector:NSSelectorFromString(propertyName)];
                                           );
    };
    
    return icp_block;
}

@end
```

- 在cell中调用

```

#pragma mark - BFDisplayProtocol

- (void)em_displayWithModel:(CircleItem *)model {
    self.titleLabel.text = model.em_property(@"name2");
    ......
}
```
>梳理一下调用流程：调用model的name2属性，通过em_exchangeKeyFromPropertyName方法返回属性映射关系找到name，然后通过消息转发调用name属性。

至此间接了完成cell对model的依赖，如果只是显示属性那么已经可以重用了。那么现在问题又来了😂，如果cell中有事件处理操作，那么就无法重用了？？？

#####问题描述
实现cell中事件处理解耦

#####解决方案
1.定义点击事件的协议
```
/**
 点击事件协议
 */
@protocol BFEventManagerProtocol <NSObject>

- (void)em_didSelectItemWithModel:(BFEventModel *)eventModel;

- (NSString *)em_eventManagerWithPropertName;

@end
```
2.定义基类BFEventManager并实现BFEventManagerProtocol协议，然后定义BFEventManager的子类，在子类中实现em_didSelectItemWithModel方法。
```
static const int BFGSpacEventTypeSectionSearch           = 1;// 搜索
static const int BFGSpacEventTypeSectionBack             = 2;// 返回

@interface BFGSpaceEventManager : BFEventManager

@end

@implementation BFGSpaceEventManager

- (void)em_didSelectItemWithModel:(BFEventModel *)eventModel {
    
    NSInteger eventType = eventModel.eventType;
    
    switch ( eventType ) {
        case BFGSpacEventTypeSectionSearch:
        {
            // 搜索
            [BFAnalyticsHelper event:@"GatherPlace_MorePlaceChoice_MoreNearby"];
            
            [[LKGlobalNavigationController sharedInstance] pushViewControllerWithUrLPattern:URL_GS_SEARCH_LIST];
            
        }
            break;
        case BFGSpacEventTypeSectionBack:
        {
            // 返回
            [BFAnalyticsHelper event:@"GatherPlace_Scan"];
          
            [[LKGlobalNavigationController sharedInstance] popPPViewController];
            
        }
            break;
        default:
            break;
    }
}
```
3.在controller初始化BFEventManager
```
- (BFEventManager *)eventManager {
    if( !_eventManager ) {
        _eventManager = [[BFGSpaceEventManager alloc] initWithTarget:self];
    }
    return _eventManager;
}
```
4.在cell中调用事件处理
```
- (void)em_displayWithModel:(CircleItem *)model {
    @weakify(self)
    [self.button addActionHandler:^(NSInteger tag) {
        @normalize(self)
        [self.eventManager em_didSelectItemWithModel:model];
    }];
    ......
}
```
>现在将cell中的事件处理交由EventManager处理，如果重用cell，只需传入不同的eventType，然后在EventManager的子类中根据不同的eventType做相应的处理。这样cell就可以完全重用了，而且页面的事件做到了统一管理，相同的事件处理还可以重用。实际项目中还体会了统一管理的好处，就是当别人还去繁杂的页面去寻找事件设置埋点时，而你却只需要优雅的打开EventManager设置埋点了。

以上就算是抛砖引玉吧，排版有点乱，代码可以在[这里](https://github.com/wans3112/BFDisplayEvent)找到，如果觉得有帮助顺便加个🌟，谢谢😁😁。