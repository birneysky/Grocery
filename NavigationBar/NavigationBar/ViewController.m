//
//  ViewController.m
//  NavigationBar
//
<<<<<<< HEAD
//  Created by birneysky on 2018/8/2.
//  Copyright © 2018年 Grocery. All rights reserved.
//

#import "ViewController.h"
#import "GSTitleView.h"

@interface ViewController ()

@property(nonatomic,strong) GSTitleView* titleView;

=======
//  Created by birney on 2018/7/27.
//  Copyright © 2018年 GroceyStore. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

>>>>>>> 4fd52405013f462c85348bb00e0e1e1c41a39a45
@end

@implementation ViewController

<<<<<<< HEAD
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
=======
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.ttView.title = @"are you kidding me ?";
    self.navigationItem.title = @"are you kidding me ?";
    UIBarButtonItem* nextIteme = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextAction)];
    self.navigationItem.rightBarButtonItems = @[nextIteme];
    UIBarButtonItem* leftIteme = [[UIBarButtonItem alloc] initWithTitle:@"TT" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.leftBarButtonItems =  @[leftIteme];
>>>>>>> 4fd52405013f462c85348bb00e0e1e1c41a39a45
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
