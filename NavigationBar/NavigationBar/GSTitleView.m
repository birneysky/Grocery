//
//  GSTitleView.m
//  NavigationBar
//
//  Created by birneysky on 2018/8/2.
//  Copyright © 2018年 Grocery. All rights reserved.
//

#import "GSTitleView.h"

@interface GSTitleView ()

@property(nonatomic,strong) UILabel* titleLabel;
@property(nonatomic,strong) UILabel* subtitleLabel;


@end

@implementation GSTitleView

#pragma mark - Properties
- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    }
    return _titleLabel;
}

#pragma mark - Override
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return UILayoutFittingExpandedSize;
}

- (void)layoutSubviews {
    CGFloat width = self.superview.superview.frame.size.width;//[UIScreen mainScreen].bounds.size.width;
    CGFloat titleWidth = width - 2 * 100;
    self.frame = CGRectMake((width-titleWidth)/2, 0, titleWidth, 44);
    self.titleLabel.frame = self.bounds;
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.titleLabel.text = _title;
}
@end
