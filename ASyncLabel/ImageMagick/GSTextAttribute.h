//
//  RCETextAttribute.h
//  ImageMagick
//
//  Created by zhaobingdong on 2018/3/21.
//  Copyright © 2018年 one. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//typedef NS_ENUM(NSUInteger, RCETextCheckingType) {
//    RCETextCheckingTypeLink = 0,
//    RCETextCheckingTypePhoneNumber = 1
//};

@interface GSTextAttribute : NSObject

@property (class,nonatomic,readonly) NSString* name;
@property (nonatomic,readonly,copy) NSDictionary* attributes;

@property (nonatomic, strong) UIColor *foregroundcolor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) NSUnderlineStyle underLineStyle;
@property (nonatomic, strong) UIColor *underLineColor;

//- (instancetype)initWithCheckingType:(RCETextCheckingType)type;

+(instancetype)defaultAttribute;

@end



@interface GSTextHighlightedAttribute : GSTextAttribute

@property (nonatomic, assign) UIEdgeInsets backgroudInset;
@property (nonatomic, assign) CGFloat backgroudRadius;

+(instancetype)defaultTextHiglightedAttribute;

@end

NS_ASSUME_NONNULL_END
