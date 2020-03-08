//
//  GSAudioOutputNode+Private.h
//  AudioEngine
//
//  Created by birney on 2020/3/6.
//  Copyright © 2020 Pea. All rights reserved.
//

#import "GSAudioOutputNode.h"

NS_ASSUME_NONNULL_BEGIN
@class GSAudioNode;

@interface GSAudioOutputNode (Private)

- (void)associate:(GSAudioNode*)node;
- (void)initialize;
- (void)start;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
