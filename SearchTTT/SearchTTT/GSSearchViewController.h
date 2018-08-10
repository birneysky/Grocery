//
//  RCESearchViewController.h
//  Search
//
//  Created by zhaobingdong on 2017/12/6.
//  Copyright © 2017年 Search. All rights reserved.
//


@import UIKit;
NS_ASSUME_NONNULL_BEGIN
@class GSSearchBar;
@class GSSearchViewController;

@protocol GSSearchResultsUpdating <NSObject>
@required
- (void)updateSearchResultsForSearchController:(GSSearchViewController *)searchController;
@end

@interface GSSearchViewController : UIViewController

- (instancetype)initWithSearchResultsController:(nullable UIViewController *)searchResultsController;

@property (nonatomic,strong,readonly) GSSearchBar* searchBar;

@property (nullable, nonatomic, weak) id <GSSearchResultsUpdating> searchResultsUpdater;

@end
NS_ASSUME_NONNULL_END
