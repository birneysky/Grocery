//
//  ViewController.m
//  NavigationBar
//
//  Created by birney on 2018/7/27.
//  Copyright © 2018年 GroceyStore. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.ttView.title = @"are you kidding me ?";
    self.navigationItem.title = @"are you kidding me ?";
    UIBarButtonItem* nextIteme = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextAction)];
    self.navigationItem.rightBarButtonItems = @[nextIteme];
    UIBarButtonItem* leftIteme = [[UIBarButtonItem alloc] initWithTitle:@"TT" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.leftBarButtonItems =  @[leftIteme];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
