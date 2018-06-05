//
//  RCESearchViewController.h
//  Search
//
//  Created by zhaobingdong on 2017/12/6.
//  Copyright © 2017年 Search. All rights reserved.
//


@import UIKit;
NS_ASSUME_NONNULL_BEGIN
@class STSearchBar;
@class STSearchViewController;

@protocol STSearchResultsUpdating <NSObject>
@required
- (void)updateSearchResultsForSearchController:(STSearchViewController *)searchController;
@end

@interface STSearchViewController : UIViewController

- (instancetype)initWithSearchResultsController:(nullable UIViewController *)searchResultsController;

@property (nonatomic,strong,readonly) STSearchBar* searchBar;

@property (nullable, nonatomic, weak) id <STSearchResultsUpdating> searchResultsUpdater;

@end
NS_ASSUME_NONNULL_END
