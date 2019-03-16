//
//  GSMonitorViewController.m
//  testaa
//
//  Created by birney on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "GSMonitorViewController.h"
#import "GSCollectionViewSeparatorLayout.h"


@interface GSMonitorViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic,strong) UICollectionView* collectionView;
@end

@implementation GSMonitorViewController

- (void)loadView {
    [super loadView];
    [self.view addSubview:self.collectionView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Monitor";
    [self.collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"rtc_value_cell"];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 14;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell =
        [self.collectionView dequeueReusableCellWithReuseIdentifier:@"rtc_value_cell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - Getters & Setters
- (UICollectionView*)collectionView {
    if (!_collectionView) {
        CGRect frame = [UIScreen mainScreen].bounds;
        GSCollectionViewSeparatorLayout* layout =
            [[GSCollectionViewSeparatorLayout alloc] initWithSeparatorWidth:1 separatorColor:[UIColor blueColor]];
        layout.sectionInset = UIEdgeInsetsMake(0, 8, 20, 8);
        layout.itemSize = (CGSize){(frame.size.width-16)/7,44};
        layout.scrollDirection =  UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.bounces = YES;
    }
    return _collectionView;
}
@end
