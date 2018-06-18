//
//  TestFlowLayout.m
//  ImageMagick
//
//  Created by birney on 2018/6/12.
//  Copyright © 2018年 one. All rights reserved.
//

#import "GSTestFlowLayout.h"

@interface GSTestFlowLayout()

@end

@implementation GSTestFlowLayout

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}



//- (void)finalizeLayoutTransition {
//
//}
//
//- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
//    return proposedContentOffset;
//}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    /// self.collectionView.contentSize.height 此时获取到的contentsize 是变化前的
    CGFloat offset = self.newContentSize.height - self.collectionView.contentSize.height;
    if (offset > 0) {
        proposedContentOffset.y += offset;
    }
     return proposedContentOffset;
}


@end
