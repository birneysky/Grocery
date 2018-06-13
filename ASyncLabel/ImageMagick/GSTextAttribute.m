//
//  RCETextAttribute.m
//  ImageMagick
//
//  Created by zhaobingdong on 2018/3/21.
//  Copyright © 2018年 one. All rights reserved.
//

#import "GSTextAttribute.h"

@interface GSTextAttribute ()

@property (nonatomic,copy) NSString* name;
@property (nonatomic,strong) NSMutableDictionary* mAttributes;

@end

@implementation GSTextAttribute

#pragma mark - Properties
- (NSMutableDictionary*)mAttributes {
    if (!_mAttributes) {
        _mAttributes = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    return _mAttributes;
}

#pragma mark - init
//- (instancetype)initWithCheckingType:(RCETextCheckingType)type {
//    if (self = [super init]) {
//        if (type == RCETextCheckingTypeLink) {
//            self.name = @"RCELink";
//        } else if (type == RCETextCheckingTypePhoneNumber) {
//            self.name = @"RCEPhoneNumber";
//        }
//    }
//    return self;
//}

+ (instancetype)defaultAttribute {
    GSTextAttribute* attribute = [[GSTextAttribute alloc] init];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentLeft;
    paragraph.lineSpacing = 0;
    paragraph.lineHeightMultiple = 0;
    paragraph.lineBreakMode = NSLineBreakByCharWrapping;
    [attribute setParagraphStyle:[paragraph copy]];
    attribute.font = [UIFont systemFontOfSize:17.0f];
    return attribute;
}

+ (NSString*)name {
    return @"RCETextAttribute";
}

- (void)setParagraphStyle:(NSParagraphStyle*)style{
    self.mAttributes[NSParagraphStyleAttributeName] = style;
}

- (UIColor*)foregroundcolor  {
    return self.mAttributes[NSForegroundColorAttributeName];
}

- (void)setForegroundcolor:(UIColor *)foregroundcolor {
    self.mAttributes[NSForegroundColorAttributeName] = foregroundcolor;
}

- (UIFont*)font {
    return self.mAttributes[NSFontAttributeName];
}

- (void)setFont:(UIFont *)font {
    self.mAttributes[NSFontAttributeName] = font;
}

- (UIColor*)backgroundColor {
    return self.mAttributes[NSBackgroundColorAttributeName];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.mAttributes[NSBackgroundColorAttributeName] = backgroundColor;
}

- (NSUnderlineStyle)underLineStyle {
    return [self.mAttributes[NSUnderlineStyleAttributeName] integerValue];
}

- (void)setUnderLineStyle:(NSUnderlineStyle)underLineStyle {
    self.mAttributes[NSUnderlineStyleAttributeName] = @(underLineStyle);
}

- (UIColor*)underLineColor {
    return self.attributes[NSUnderlineColorAttributeName];
}

- (void)setUnderLineColor:(UIColor *)underLineColor {
    self.mAttributes[NSUnderlineColorAttributeName] = underLineColor;
}

- (NSDictionary*)attributes {
    return [self.mAttributes copy];
}

@end


@implementation GSTextHighlightedAttribute

+ (NSString*)name {
    return @"RCETextHighlightedAttribute";
}

+ (instancetype)defaultTextHiglightedAttribute {
    GSTextHighlightedAttribute* attribute = [[GSTextHighlightedAttribute alloc] init];
    attribute.foregroundcolor = [UIColor whiteColor];
    attribute.backgroundColor = [UIColor blueColor];
    return attribute;
}

@end
