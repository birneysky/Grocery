//
//  TestFlowLayout.m
//  ImageMagick
//
//  Created by birney on 2018/6/12.
//  Copyright © 2018年 one. All rights reserved.
//

#import "TestFlowLayout.h"

@interface TestFlowLayout()

//@property(nonatomic,assign) CGSize oldContentSize;

@end

@implementation TestFlowLayout

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    NSLog(@"😓😓😓😓😓😓😓😓 targetContentOffsetForProposedContentOffset %@  contentsize %@,contentOffset %@",NSStringFromCGPoint(proposedContentOffset),NSStringFromCGSize(self.collectionView.contentSize),NSStringFromCGPoint(self.collectionView.contentOffset));
    CGFloat offset = self.newContentSize.height - self.collectionView.contentSize.height;
    proposedContentOffset.y += offset;

     return proposedContentOffset;
}


@end
