//
//  GSSeparatorView.m
//  testaa
//
//  Created by birney on 2019/3/12.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "GSSeparatorView.h"
#import "GSCollectionViewColoredLayoutAttributes.h"
@implementation GSSeparatorView
- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    if ([layoutAttributes isMemberOfClass:GSCollectionViewColoredLayoutAttributes.class]) {
        GSCollectionViewColoredLayoutAttributes* attributes = (GSCollectionViewColoredLayoutAttributes*)layoutAttributes;
        self.backgroundColor = attributes.color;
    }
}
@end
