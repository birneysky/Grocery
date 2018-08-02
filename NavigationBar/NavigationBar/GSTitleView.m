//
//  GSTitleView.m
<<<<<<< HEAD
//  NavigationBar
//
//  Created by birneysky on 2018/8/2.
//  Copyright © 2018年 Grocery. All rights reserved.
=======
//  AsyncImageView
//
//  Created by birney on 2018/7/26.
//  Copyright © 2018年 Weilai. All rights reserved.
>>>>>>> 4fd52405013f462c85348bb00e0e1e1c41a39a45
//

#import "GSTitleView.h"

@interface GSTitleView ()

<<<<<<< HEAD
@property(nonatomic,strong) UILabel* titleLabel;
@property(nonatomic,strong) UILabel* subtitleLabel;


@end

@implementation GSTitleView

#pragma mark - Properties
=======
@property (nonatomic,strong) UILabel* titleLabel;
@property (nonatomic,assign) CGSize textSize;

@end;

@implementation GSTitleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
>>>>>>> 4fd52405013f462c85348bb00e0e1e1c41a39a45
- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
<<<<<<< HEAD
=======
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
>>>>>>> 4fd52405013f462c85348bb00e0e1e1c41a39a45
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    }
    return _titleLabel;
}

<<<<<<< HEAD
#pragma mark - Override
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        self.backgroundColor = [UIColor clearColor];
=======
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.contentMode = UIViewContentModeRedraw;
        //self.layoutGuides
        [self addSubview:self.titleLabel];
>>>>>>> 4fd52405013f462c85348bb00e0e1e1c41a39a45
    }
    return self;
}

- (CGSize)intrinsicContentSize {
<<<<<<< HEAD
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
=======
    return CGSizeMake(126, 44);
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    [UIView animateWithDuration:0.25 animations:^{
    self.titleLabel.frame = (CGRect){(self.bounds.size.width - self.textSize.width) / 2, (self.bounds.size.height - self.textSize.height) / 2,self.textSize.width,self.textSize.height};
//    }];
}

//- (void)drawRect:(CGRect)rect {
    //[@"234" drawAtPoint:CGPointMake(0, 0) withAttributes:nil];
//    NSString* text = @"23467891";
//    NSAttributedString* attString = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f],NSForegroundColorAttributeName:[UIColor redColor]}];
//    CGSize size =  [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.0f],NSForegroundColorAttributeName:[UIColor redColor]}];
//    [attString drawInRect:CGRectMake((rect.size.width - size.width) / 2, (rect.size.height-size.height)/2, size.width, size.height)];
//    [attString drawInRect:CGRectMake((rect.size.width - size.width) / 2, (rect.size.height-size.height)/2, size.width, size.height) withAttributes:nil];
//}

- (void)setTitle:(NSString *)title {
    self.textSize = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18.0f]}];
    if (self.textSize.width > 126) {
        self.textSize = (CGSize){126,self.textSize.height};
    }
    self.titleLabel.text = title;
}

//- (void)setFrame:(CGRect)frame {
//    return;
//    [super setFrame:frame];
//}

>>>>>>> 4fd52405013f462c85348bb00e0e1e1c41a39a45
@end
