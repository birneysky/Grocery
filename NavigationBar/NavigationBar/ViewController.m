//
//  ViewController.m
//  NavigationBar
//
//  Created by birney on 2018/8/3.
//  Copyright © 2018年 GroceyStore. All rights reserved.
//

#import "ViewController.h"
#import "GSTitleView.h"

@interface ViewController ()
@property (nonatomic,strong) GSTitleView* titleView;
@end

@implementation ViewController


- (GSTitleView*)titleView {
    if (!_titleView) {
        _titleView = [[GSTitleView alloc] initWithFrame:CGRectZero];
    }
    return _titleView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.titleView.title = @"are you kidding me";
//    self.titleView.subTitle = @"hello";
//    self.navigationItem.titleView = self.titleView;
    self.title = @"hello";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
