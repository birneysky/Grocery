//
//  AppleProduct.m
//  SearchTTT
//
//  Created by zhaobingdong on 2018/1/9.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "AppleProduct.h"

@implementation AppleProduct

+ (AppleProduct *)productWithType:(NSString *)type name:(NSString *)name year:(NSNumber *)year price:(NSNumber *)price {
    AppleProduct *newProduct = [[self alloc] init];
    newProduct.hardwareType = type;
    newProduct.title = name;
    newProduct.yearIntroduced = year;
    newProduct.introPrice = price;
    
    return newProduct;
}

+ (NSString *)deviceTypeTitle {
    return NSLocalizedString(@"Device", @"Device type title");
}
+ (NSString *)desktopTypeTitle {
    return NSLocalizedString(@"Desktop", @"Desktop type title");
}
+ (NSString *)portableTypeTitle {
    return NSLocalizedString(@"Portable", @"Portable type title");
}

+ (NSArray *)deviceTypeNames {
    static NSArray *deviceTypeNames = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        deviceTypeNames = @[[AppleProduct deviceTypeTitle], [AppleProduct portableTypeTitle], [AppleProduct desktopTypeTitle]];
    });
    
    return deviceTypeNames;
}

+ (NSString *)displayNameForType:(NSString *)type {
    static NSMutableDictionary *deviceTypeDisplayNamesDictionary = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        deviceTypeDisplayNamesDictionary = [[NSMutableDictionary alloc] init];
        for (NSString *deviceType in self.deviceTypeNames) {
            NSString *displayName = NSLocalizedString(deviceType, @"dynamic");
            deviceTypeDisplayNamesDictionary[deviceType] = displayName;
        }
    });
    
    return deviceTypeDisplayNamesDictionary[type];
}

@end
