//
//  BFPropertyExchange.h
//  Pods
//
//  Created by wans on 2017/4/10.
//
//

#import <Foundation/Foundation.h>

@protocol BFPropertyExchangeProtocol <NSObject>

- (NSDictionary *)em_exchangeKeyFromPropertyName;

@end

@interface NSObject (PropertyExchange)

/**
 调用替换属性 Invocation property
 */
@property (nonatomic, copy) id(^em_property)(NSString *propertyName);

@end

@interface BFPropertyExchange : NSObject<BFPropertyExchangeProtocol>


@end
