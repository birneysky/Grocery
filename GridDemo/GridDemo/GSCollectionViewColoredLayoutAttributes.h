//
//  GSCollectionViewColoredLayoutAttributes.h
//  testaa
//
//  Created by birney on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSCollectionViewColoredLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, strong) UIColor* color;
+ (instancetype)coloredLayoutAttributesForDecorationViewOfKind:(NSString *)elementKind withIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
