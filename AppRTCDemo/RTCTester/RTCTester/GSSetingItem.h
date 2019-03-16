//
//  RTSetingItem.h
//  RTCTester
//
//  Created by birney on 2019/1/14.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString* const RTNameKey;
extern NSString* const RTValueKey;

@interface GSSetingItem : NSObject

@property(nonatomic,copy) NSString* name;
@property(nonatomic,assign) NSUInteger value;

- (instancetype)init:(NSDictionary*)dic;

@end



extern NSString* const RTReuseKey;
extern NSString* const RTTitleKey;
extern NSString* const RTOptionskey;

@interface GSSettingGroupItem : NSObject

@property(nonatomic,copy) NSString* reuseKey;
@property(nonatomic,copy) NSString* title;
@property(nonatomic,copy) NSArray<GSSetingItem*>* options;

- (instancetype)init:(NSDictionary*)dic;

@end;


NS_ASSUME_NONNULL_END
