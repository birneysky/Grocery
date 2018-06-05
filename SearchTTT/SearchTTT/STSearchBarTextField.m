//
//  RCESearchBarTextField.m
//  SearchTTT
//
//  Created by zhaobingdong on 2018/1/8.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "STSearchBarTextField.h"

@implementation STSearchBarTextField

#pragma mark - Init
- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - Override
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectMake(24, 0, bounds.size.width - 26, bounds.size.height);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return CGRectMake(24, 0, bounds.size.width - 26, bounds.size.height);
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(24, 0, bounds.size.width - 26, bounds.size.height);
}

- (void)setText:(NSString *)text {
    [super setText:text];
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter postNotificationName:UITextFieldTextDidChangeNotification
                                 object:self];
}

@end
