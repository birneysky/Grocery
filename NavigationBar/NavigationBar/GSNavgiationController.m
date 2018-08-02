//
//  GSNavgiationController.m
//  AsyncImageView
//
//  Created by zhaobingdong on 2018/7/27.
//  Copyright © 2018年 Weilai. All rights reserved.
//

#import "GSNavgiationController.h"
#import "GSNavigationBar.h"

@interface GSNavgiationController ()

@property(nonatomic,strong)GSNavigationBar* gsBar;

@end

@implementation GSNavgiationController

#pragma mark - Properties
- (GSNavigationBar*)gsBar {
    if (!_gsBar) {
        _gsBar = [[GSNavigationBar alloc] init];
        //_gsBar.delegate = self;
    }
    return _gsBar;
}

#pragma mark - Life Cyle
- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.navigationBar setValue:self.gsBar forKey:@"navigationBar"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - override
//- (UINavigationBar*)navigationBar {
//    return self.gsBar;
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
