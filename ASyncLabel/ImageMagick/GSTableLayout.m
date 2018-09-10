//
//  GSTableLayout.m
//  ImageMagick
//
//  Created by birneysky on 2018/9/10.
//  Copyright © 2018年 one. All rights reserved.
//

#import "GSTableLayout.h"

@implementation GSTableViewLayout

-(void) prepareLayout {
    
    const CGFloat interItemSpacing = 14.0f;
    const CGFloat itemWidth = self.collectionView.bounds.size.width;
    NSInteger numSections = [self.collectionView numberOfSections];
    CGFloat y = 0;
    for(NSInteger section = 0; section < numSections; section++)  {
        NSInteger numItems = [self.collectionView numberOfItemsInSection:section];
        for(NSInteger item = 0; item < numItems; item++){
           NSIndexPath* indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *itemAttributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            CGFloat height = [self.delegate
                              collectionView:self.collectionView
                              heightForItemAtIndexPath:indexPath];

            itemAttributes.frame = (CGRect){0,y,itemWidth,height};
            y += height + interItemSpacing;
        }
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    return nil;
}

@end
