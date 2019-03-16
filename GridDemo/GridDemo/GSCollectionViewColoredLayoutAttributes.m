//
//  GSCollectionViewColoredLayoutAttributes.m
//  testaa
//
//  Created by birney on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "GSCollectionViewColoredLayoutAttributes.h"

@interface GSCollectionViewColoredLayoutAttributes ()

@end

@implementation GSCollectionViewColoredLayoutAttributes
+ (instancetype)coloredLayoutAttributesForDecorationViewOfKind:(NSString *)elementKind withIndexPath:(NSIndexPath *)indexPath {
    GSCollectionViewColoredLayoutAttributes* attributes= [GSCollectionViewColoredLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind withIndexPath:indexPath];

    attributes.color = [UIColor redColor];
    return attributes;
}
@end
