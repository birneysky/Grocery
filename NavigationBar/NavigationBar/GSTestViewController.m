//
//  GSTestViewController.m
//  NavigationBar
//
//  Created by birney on 2018/8/3.
//  Copyright © 2018年 GroceyStore. All rights reserved.
//

#import "GSTestViewController.h"
#import "GSTitleView.h"

@interface GSTestViewController ()
@property (nonatomic,strong) GSTitleView* titleView;
@end

@implementation GSTestViewController
- (GSTitleView*)titleView {
    if (!_titleView) {
        _titleView = [[GSTitleView alloc] initWithFrame:(CGRect){0,0,200,44}];
    }
    return _titleView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleView.title = @"are you kidding me";
      self.titleView.subTitle = @"helloxxxx";
    self.navigationItem.titleView = self.titleView;
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
