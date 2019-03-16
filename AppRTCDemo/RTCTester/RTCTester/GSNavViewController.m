//
//  RTNavViewController.m
//  RTCTester
//
//  Created by birney on 2019/1/10.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "GSNavViewController.h"

@interface GSNavViewController ()

@end

@implementation GSNavViewController

- (void)loadView {
    [super loadView];
    [self.navigationBar
        setBackgroundImage:[UIImage new]
        forBarPosition:UIBarPositionTop
        barMetrics:UIBarMetricsDefault];
    [self.navigationBar
        setShadowImage:[UIImage new]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
