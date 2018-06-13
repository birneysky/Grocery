//
//  TestHeaderView.m
//  ImageMagick
//
//  Created by birney on 2018/6/13.
//  Copyright © 2018年 one. All rights reserved.
//

#import "TestHeaderView.h"

@interface TestHeaderView()
@property(nonatomic,strong) UIActivityIndicatorView* indicator;
@end

@implementation TestHeaderView

- (UIActivityIndicatorView*)indicator{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _indicator;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //self.backgroundColor = [UIColor whiteColor];
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addSubview:self.indicator];
}

- (void)layoutSubviews {
    self.indicator.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height/2);
}

- (void)startAnimating {
    [self.indicator startAnimating];
}

- (void)stopAnimating {
    [self.indicator stopAnimating];
}

@end
