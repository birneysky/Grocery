//
//  UIResponder+Grocery.h
//  ResponderChainInteraction
//
//  Created by birney on 2018/7/13.
//  Copyright © 2018年 Grocery. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (Grocery)

- (void)routerEventWithName:(NSString *)eventName
                   userInfo:(NSDictionary *)userInfo;

@end
