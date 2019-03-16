//
//  RTSetingItem.m
//  RTCTester
//
//  Created by birney on 2019/1/14.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "GSSetingItem.h"

NSString* const RTNameKey =  @"name";
NSString* const RTValueKey = @"value";

@implementation GSSetingItem

- (instancetype)init:(NSDictionary *)dic{
    if(self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}
@end

NSString* const RTReuseKey =  @"reuseKey";
NSString* const RTTitleKey = @"title";
NSString* const RTOptionskey = @"options";

@implementation GSSettingGroupItem

- (instancetype)init:(NSDictionary *)dic{
    if(self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

@end
