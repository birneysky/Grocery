//
//  GSAudioNode.h
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 Pea. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "GSAudioTypes.h"

NS_ASSUME_NONNULL_BEGIN
@class GSAudioUnit;

FOUNDATION_EXTERN const GSAudioNodeBus InvalidAudioBus;

@interface GSAudioNode : NSObject <NSCopying>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) GSAudioUnit* audioUnit;
@property (nonatomic, readonly) NSUInteger numberOfInputs;
@property (nonatomic, readonly) NSUInteger numberOfOutputs;
@property (nonatomic, readonly) GSAudioNodeBus availableInputBus; /// 如果不存在返回 InvalidAudioBus
@property (nonatomic, readonly) GSAudioNodeBus availableOutputBus; /// 如果不存在返回 InvalidAudioBus
- (AVAudioFormat *)inputFormatForBus:(GSAudioNodeBus)bus;
- (AVAudioFormat *)outputFormatForBus:(GSAudioNodeBus)bus;
@end

NS_ASSUME_NONNULL_END
