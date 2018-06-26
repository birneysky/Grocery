//
//  GSViewController.m
//  SearchTTT
//
//  Created by birney on 2018/6/15.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "GSViewController.h"

NSString* const tag = @"dev";

@interface GSViewController ()

@end

@implementation GSViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wilResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    ///   键盘通知的正确注册方式
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"%@ GSViewController viewWillDisappear",tag);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%@ GSViewController viewDidAppear",tag);
}

#pragma mark - Notification selector
-(void)keyboardWillShow {
    NSLog(@"%@ GSViewController keyboardWillShow",tag);
}

- (void)keyboardWillHide {
    NSLog(@"%@ GSViewController keyboardWillHide",tag);
}

- (void)wilResignActive {
    NSLog(@"%@ GSViewController wilResignActive",tag);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)didBecomeActive {
    NSLog(@"%@ GSViewController didBecomeActive",tag);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
