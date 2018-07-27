//
//  UINavigationBar+GS.m
//  AsyncImageView
//
//  Created by birney on 2018/7/27.
//  Copyright © 2018年 Weilai. All rights reserved.
//

#import "UINavigationBar+GS.h"

@implementation UINavigationBar (GS)
//- (NSArray<UINavigationItem *> *)items {
//    return nil;
//}
//
//- (instancetype)initWithFrame:(CGRect)frame {
//    if (self = [super initWithFrame:frame]) {
//        [self setUp];
//    }
//    return self;
//}
//
//- (instancetype)init {
//    if (self = [super init]) {
//        [self setUp];
//    }
//    return self;
//}

//- (instancetype)initWithCoder:(NSCoder *)aDecoder {
//    if (self = [super initWithCoder:aDecoder]) {
//        [self setUp];
//    }
//    return self;
//}
//
- (void)setUp {

}

//-(void)awakeFromNib {
    //[super awakeFromNib];
//    UIButton* leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftBtn setTitle:@"123" forState:UIControlStateNormal];
//    [self addSubview:leftBtn];
    
//}

//- (void)setItems:(NSArray<UINavigationItem *> *)items {
//
//}
//
//- (void)setItems:(NSArray<UINavigationItem *> *)items animated:(BOOL)animated {
//
//}
//
//- (void)pushNavigationItem:(UINavigationItem *)item animated:(BOOL)animated {
//
//}
//
//- (nullable UINavigationItem *)popNavigationItemAnimated:(BOOL)animated {
//    return nil;
//}

//- (void)willMoveToWindow:(nullable UIWindow *)newWindow {
//
//}

//-(void)addSubview:(UIView *)view {
//
//}

- (void)didAddSubview:(UIView *)subview {
    Class type = NSClassFromString(@"_UINavigationBarContentView");
    if ([subview isKindOfClass:type]) {
//        [subview removeConstraints:subview.constraints];
//        NSArray<UILayoutGuide*>* guides = subview.layoutGuides;
//        //for(UILayoutGuide* guide in guides) {
//            //[subview removeLayoutGuide:guide];
//        //}
        [subview removeFromSuperview];
    }
}
//- (void)didMoveToSuperview {
//
//}
//
//- (void)didMoveToWindow {
//
//}

//-(void)addConstraint:(NSLayoutConstraint *)constraint {
//
//}
//
//- (void)addConstraints:(NSArray<__kindof NSLayoutConstraint *> *)constraints {
//
//}


//
//
//- (void)addLayoutGuide:(UILayoutGuide *)layoutGuide {
//
//}

@end
