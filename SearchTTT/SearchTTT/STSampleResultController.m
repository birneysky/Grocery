//
//  RCESampleResultController.m
//  SearchTTT
//
//  Created by zhaobingdong on 2018/1/9.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

#import "STSampleResultController.h"
#import "STSampleDetailViewController.h"

@interface STSampleResultController ()

@end

@implementation STSampleResultController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SampleResult"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"SampleResult"];
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    }
    // Configure the cell...
    AppleProduct* product = self.products[indexPath.row];
    // Configure the cell...
    cell.textLabel.text = product.title;
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    NSString *priceString = [numberFormatter stringFromNumber:product.introPrice];
    
    NSString *detailedStr = [NSString stringWithFormat:@"%@ | %@", priceString, (product.yearIntroduced).stringValue];
    cell.detailTextLabel.text = detailedStr;
    
    return cell;
}

#pragma mark - TableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    STSampleDetailViewController* sdvc = [[STSampleDetailViewController alloc] init];
    [self.navigationController pushViewController:sdvc animated:YES];
}


@end
