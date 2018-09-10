//
//  GSTableLayout.h
//  ImageMagick
//
//  Created by birneysky on 2018/9/10.
//  Copyright © 2018年 one. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GSTableViewLayoutDelegate <NSObject>
@required
- (CGFloat) collectionView:(UICollectionView*) collectionView
  heightForItemAtIndexPath:(NSIndexPath*) indexPath;
@end

@interface GSTableViewLayout : UICollectionViewLayout

@property(nonatomic,weak) id<GSTableViewLayoutDelegate> delegate;

@end
