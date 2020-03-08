//
//  GSAudioUnit+Private.h
//  AudioEngine
//
//  Created by birney on 2020/3/2.
//  Copyright © 2020 Pea. All rights reserved.
//


#import "GSAudioUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSAudioUnit (Private)

/// 引擎图中索引
@property (nonatomic, assign) AUNode auNode;
- (void)setAudioUnit:(AudioUnit)unit;
- (AudioUnit _Nonnull &)audioUnitRef;
@end

NS_ASSUME_NONNULL_END
