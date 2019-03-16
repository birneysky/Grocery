//
//  GSCollectionViewSeparatorLayout.m
//  testaa
//
//  Created by birney on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "GSCollectionViewSeparatorLayout.h"
#import "GSSeparatorView.h"
#import "GSCollectionViewColoredLayoutAttributes.h"

typedef NSString *const GSDecorationElementKind;

GSDecorationElementKind topSeparatorKind = @"GSCollectionViewSeparatorLayout.Top";
GSDecorationElementKind bottomSeparatorKind = @"GSCollectionViewSeparatorLayout.Bottom";
GSDecorationElementKind leftSeparatorKind = @"GSCollectionViewSeparatorLayout.Left";
GSDecorationElementKind rightSeparatorKind = @"GSCollectionViewSeparatorLayout.Right";

@interface GSCollectionViewSeparatorLayout ()


@property (nonatomic) CGFloat separatorWidth;
@property (nonatomic) NSUInteger columns; /// 每一行的数量

@property (nonatomic, strong) UIColor* separatorColor;
@end

@implementation GSCollectionViewSeparatorLayout

-(instancetype)initWithSeparatorWidth:(CGFloat)width separatorColor:(UIColor*)color {
    if (self = [super init]) {
        self.separatorWidth = width;
        self.separatorColor = color;
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing = 0;
    }
    return self;
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing {
    [super setMinimumLineSpacing:0];
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing {
    [super setMinimumInteritemSpacing:0];
}

- (void)prepareLayout {
    [super prepareLayout];
    CGFloat collectionViewWidth = self.collectionView.bounds.size.width;
    self.columns =  (collectionViewWidth - self.sectionInset.left - self.sectionInset.right )/ self.itemSize.width;
    [self registerClass:GSSeparatorView.class forDecorationViewOfKind:topSeparatorKind];
    [self registerClass:GSSeparatorView.class forDecorationViewOfKind:bottomSeparatorKind];
    [self registerClass:GSSeparatorView.class forDecorationViewOfKind:leftSeparatorKind];
    [self registerClass:GSSeparatorView.class forDecorationViewOfKind:rightSeparatorKind];
}

- (UICollectionViewLayoutAttributes*)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind
                                                                 atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* cellAttributes =  [self layoutAttributesForItemAtIndexPath:indexPath];
    CGRect frame = CGRectZero;
    if (cellAttributes) {
        frame = cellAttributes.frame;
    }
    
    GSCollectionViewColoredLayoutAttributes* layoutAttributes = [GSCollectionViewColoredLayoutAttributes coloredLayoutAttributesForDecorationViewOfKind:elementKind withIndexPath:indexPath];
    CGFloat maxX = CGRectGetMaxX(frame);
    CGFloat minX = CGRectGetMinX(frame);
    CGFloat maxY = CGRectGetMaxY(frame);
    CGFloat minY = CGRectGetMinY(frame);
    if ([elementKind isEqualToString:leftSeparatorKind]) {
        layoutAttributes.frame = CGRectMake(minX - self.separatorWidth, minY ,self.separatorWidth, frame.size.height);
    } else if ([elementKind isEqualToString:rightSeparatorKind]) {
        layoutAttributes.frame = CGRectMake(maxX , minY, self.separatorWidth, frame.size.height);
    } else if ([elementKind isEqualToString:topSeparatorKind]) {
        layoutAttributes.frame = CGRectMake(minX, minY - self.separatorWidth, frame.size.width, self.separatorWidth);
    } else if ([elementKind isEqualToString:bottomSeparatorKind]) {
        layoutAttributes.frame = CGRectMake(minX, maxY, frame.size.width, self.separatorWidth);
    } else {
    }
    layoutAttributes.zIndex = -1;
    layoutAttributes.color = self.separatorColor;
    return layoutAttributes;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray* attributes =  [super layoutAttributesForElementsInRect:rect];
    if (!attributes) {
        return nil;
    }
    NSMutableArray* layoutAttributes  = attributes.mutableCopy;
    for (UICollectionViewLayoutAttributes* item in attributes) {
        if (item.representedElementCategory == UICollectionElementCategoryCell ) {
            NSMutableArray* decorationAttributes  = [[NSMutableArray alloc] initWithCapacity:4];
            NSArray * kinds = [self separatorKinds:item.indexPath];
            for (NSString* kind in kinds) {
                UICollectionViewLayoutAttributes* decorationAttribute =
                    [self  layoutAttributesForDecorationViewOfKind:kind atIndexPath:item.indexPath];
                [decorationAttributes addObject:decorationAttribute];
            }
            [layoutAttributes addObjectsFromArray:decorationAttributes];
        }
        
    }
    return layoutAttributes;
}


- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath {
    UICollectionViewLayoutAttributes *layoutAttributes =  [self layoutAttributesForDecorationViewOfKind:elementKind atIndexPath:decorationIndexPath];
    return layoutAttributes;
}

#pragma mark - Getters
- (NSArray<GSDecorationElementKind>*)separatorKinds:(NSIndexPath*)indexpath {
    NSInteger row = [self.collectionView numberOfItemsInSection:indexpath.section] / self.columns;
    if (indexpath.item != 0 && indexpath.item / self.columns == row-1) { /// 最会一列
        if ((indexpath.item + 1) % self.columns == 0) { /// 最后一列
            return @[leftSeparatorKind, topSeparatorKind, bottomSeparatorKind, rightSeparatorKind];
        } else {
            return @[leftSeparatorKind, topSeparatorKind, bottomSeparatorKind];
        }
    } else {
        if ((indexpath.item + 1)% self.columns == 0) {
            return @[leftSeparatorKind, topSeparatorKind, rightSeparatorKind];
        } else {
            return @[leftSeparatorKind,topSeparatorKind];
        }
    }
}

@end
