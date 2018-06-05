//
//  RCESearchBar.h
//  Search
//
//  Created by zhaobingdong on 2017/1/7.
//  Copyright © 2017年 Search. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol STSearchBarDelegate;

IB_DESIGNABLE

@interface STSearchBar : UIView

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

@property (nullable,nonatomic,weak) id <STSearchBarDelegate> delegate;
@property (nullable,nonatomic,copy) NSString* text;

@end


@protocol STSearchBarDelegate <NSObject>

@optional

- (BOOL)searchBarShouldBeginEditing:(STSearchBar *)searchBar;
- (void)searchBarTextDidBeginEditing:(STSearchBar *)searchBar;
- (BOOL)searchBarShouldEndEditing:(STSearchBar *)searchBar;

@end

NS_ASSUME_NONNULL_END
