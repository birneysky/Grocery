//
//  GSTestViewController.m
//  NavigationBar
//
//  Created by birneysky on 2018/8/2.
//  Copyright © 2018年 Grocery. All rights reserved.
//

#import "GSTestViewController.h"
#import "GSTitleView.h"

@interface GSTestViewController ()
@property(nonatomic,strong) GSTitleView* titleView;
@end

@implementation GSTestViewController

#pragma mark - Properties
- (GSTitleView*)titleView {
    if (!_titleView) {
        _titleView = [[GSTitleView alloc] initWithFrame:CGRectZero];
    }
    return _titleView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = self.titleView;
    self.titleView.title = @"How you doing";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
