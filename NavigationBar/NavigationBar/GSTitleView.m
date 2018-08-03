//
//  GSTitleView.m
//  NavigationBar
//
//  Created by birneysky on 2018/8/2.
//  Copyright © 2018年 Grocery. All rights reserved.


#import "GSTitleView.h"

@interface GSTitleView ()

@property(nonatomic,strong) UILabel* titleLabel;
@property(nonatomic,strong) UILabel* subtitleLabel;


@end

@implementation GSTitleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    }
    return _titleLabel;
}

- (UILabel*)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _subtitleLabel.font = [UIFont systemFontOfSize:12];
        _subtitleLabel.textColor = [UIColor lightGrayColor];
    }
    return _subtitleLabel;
}

#pragma mark - Override

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentMode = UIViewContentModeRedraw;
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return UILayoutFittingExpandedSize;
}

- (void)layoutSubviews {
//    CGFloat width = self.superview.superview.frame.size.width;//[UIScreen mainScreen].bounds.size.width;
//    CGFloat titleWidth = width - 2 * 100;
//    self.frame = CGRectMake((width-titleWidth)/2, 0, titleWidth, 44);
//    self.titleLabel.frame = self.bounds;
    
    CGFloat totalWidth = self.superview.superview.frame.size.width;
    CGFloat titleWidth =  totalWidth - 2*100;
    //    if (self.frame.origin.x != (totalWidth-titleWidth)/2) {
    self.frame = CGRectMake((totalWidth-titleWidth)/2, 0, titleWidth, 44);
    //    }
    self.titleLabel.frame = self.bounds;
    if (self.title.length > 0 && self.subTitle.length > 0) {
        CGRect titleFrame =  self.titleLabel.frame;
        titleFrame.origin.y = 4;
        titleFrame.size.height = 22;
        self.titleLabel.frame = titleFrame;
        titleFrame.origin.y = 22;
        self.subtitleLabel.frame = titleFrame;
    }
}



#pragma mark - Helper
- (void)updateTitleText {
    if (self.subTitle.length > 0 && self.title.length > 0) {
        if (!self.subtitleLabel.superview) {
            [self addSubview:self.subtitleLabel];
        }
        self.subtitleLabel.text = self.subTitle;
        self.titleLabel.text = self.title;
    } else {
        self.titleLabel.text = self.title;
        self.subtitleLabel.text = self.subTitle;
    }
    
}

#pragma mark - Api
- (void)setTitle:(NSString *)title {
    _title = [title copy];
    [self updateTitleText];
}

- (void)setSubTitle:(NSString *)subTitle {
    _subTitle = [subTitle copy];
    [self updateTitleText];
}
@end
