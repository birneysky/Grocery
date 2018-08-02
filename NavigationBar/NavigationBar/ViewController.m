//
//  ViewController.m
//  NavigationBar
//
//  Created by birneysky on 2018/8/2.
//  Copyright © 2018年 Grocery. All rights reserved.
//

#import "ViewController.h"
#import "GSTitleView.h"

@interface ViewController ()

@property(nonatomic,strong) GSTitleView* titleView;

@end

@implementation ViewController

#pragma mark - Properties
- (GSTitleView*)titleView {
    if (!_titleView) {
        _titleView = [[GSTitleView alloc] initWithFrame:(CGRect){0,0,200,44}];
    }
    return _titleView;
}

#pragma mark - Override
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.titleView = self.titleView;
    self.titleView.title = @"areyoukiddingme";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
