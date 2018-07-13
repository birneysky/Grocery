//
//  UIResponder+Grocery.m
//  ResponderChainInteraction
//
//  Created by birney on 2018/7/13.
//  Copyright © 2018年 Grocery. All rights reserved.
//

#import "UIResponder+Grocery.h"

@implementation UIResponder (Grocery)

- (void)routerEventWithName:(NSString *)eventName
                   userInfo:(NSDictionary *)userInfo
{
    [[self nextResponder] routerEventWithName:eventName
                                     userInfo:userInfo];
}

@end
