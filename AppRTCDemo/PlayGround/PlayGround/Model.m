//
//  Model.m
//  PlayGround
//
//  Created by birney on 2019/1/19.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "Model.h"

@implementation Model
- (instancetype)initWithDictnory:(NSDictionary*)dic {
    if(self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (NSDictionary<NSString *, id> *)dictionaryWithValuesForKeys:(NSArray<NSString *> *)keys {
    return @{};
}

@end
