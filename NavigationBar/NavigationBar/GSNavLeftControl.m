//
//  GSNavLeftControl.m
//  AsyncImageView
//
//  Created by birney on 2018/7/26.
//  Copyright © 2018年 Weilai. All rights reserved.
//

#import "GSNavLeftControl.h"

@interface GSNavLeftControl ()

@property(nonatomic,strong) UIImageView* imgView;
@property(nonatomic,strong) UILabel* label;

@end


@implementation GSNavLeftControl

- (UIImageView*)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:(CGRect){-8,0,11,20}];
        _imgView.image = [UIImage imageNamed:@"common_navi_icon_left"];
    }
    return _imgView;
}

- (UILabel*)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.textColor = [UIColor colorWithRed:79/255.0f green:145/255.0f blue:236/255.0f alpha:1];
        _label.text = @"Message(123)";
    }
    return _label;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addSubview:self.imgView];
    [self addSubview:self.label];
}

- (void)layoutSubviews {
    self.imgView.frame = CGRectMake(-2, 12, 11, 20);
    //CGFloat y =  CGRectGetMaxY(self.imgView.frame);
    self.label.frame = CGRectMake(12,0, 110,44);
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(120, 44);
}


@end
