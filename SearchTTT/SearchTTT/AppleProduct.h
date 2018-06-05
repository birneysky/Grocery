//
//  AppleProduct.h
//  SearchTTT
//
//  Created by birney on 2018/1/9.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppleProduct : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *hardwareType;
@property (nonatomic, copy) NSNumber *yearIntroduced;
@property (nonatomic, copy) NSNumber *introPrice;

+ (AppleProduct *)productWithType:(NSString *)type name:(NSString *)name year:(NSNumber *)year price:(NSNumber *)price;

+ (NSArray *)deviceTypeNames;
+ (NSString *)displayNameForType:(NSString *)type;

+ (NSString *)deviceTypeTitle;
+ (NSString *)desktopTypeTitle;
+ (NSString *)portableTypeTitle;

@end
