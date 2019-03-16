//
//  RTTextField.m
//  RTCTester
//
//  Created by birney on 2019/1/11.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "GSTextField.h"

@implementation GSTextField

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + 20, bounds.origin.y, bounds.size.width - 40, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + 20, bounds.origin.y, bounds.size.width - 40, bounds.size.height);
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + 20, bounds.origin.y, bounds.size.width - 40, bounds.size.height);
}

@end
