//
//  RCESearchControllerView.m
//  Search
//
//  Created by zhaobingdong on 2017/1/7.
//  Copyright © 2017年 Search. All rights reserved.
//

#import "STSearchControllerView.h"

@implementation STSearchControllerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self.hitView;
}

@end
