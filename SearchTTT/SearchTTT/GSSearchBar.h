//
//  RCESearchBar.h
//  Search
//
//  Created by zhaobingdong on 2017/1/7.
//  Copyright © 2017年 Search. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GSSearchBarDelegate;

IB_DESIGNABLE

@interface GSSearchBar : UIView

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

@property (nullable,nonatomic,weak) id <GSSearchBarDelegate> delegate;
@property (nullable,nonatomic,copy) NSString* text;

@end


@protocol GSSearchBarDelegate <NSObject>

@optional

- (BOOL)searchBarShouldBeginEditing:(GSSearchBar *)searchBar;
- (void)searchBarTextDidBeginEditing:(GSSearchBar *)searchBar;
- (BOOL)searchBarShouldEndEditing:(GSSearchBar *)searchBar;

@end

NS_ASSUME_NONNULL_END
