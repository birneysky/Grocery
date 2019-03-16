//
//  RTPickerContainer.m
//  RTCTester
//
//  Created by birney on 2019/1/11.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "GSPickerContainer.h"

@implementation GSPickerContainer

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)doneActionn:(id)sender {
    [self.delegate done];
}

- (IBAction)cancelActionn:(id)sender {
    [self.delegate cancel];
}
@end
