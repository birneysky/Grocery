//
//  GSAudioNode.h
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN
@class GSAudioUnit;

typedef NSUInteger GSAudioNodeBus;


@interface GSAudioNode : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) GSAudioUnit* audioUnit;
@property (nonatomic, readonly) AUNode node;
@property (nonatomic, readonly) NSUInteger numberOfInputs;
@property (nonatomic, readonly) NSUInteger numberOfOutputs;
@property (nonatomic, readonly) GSAudioNodeBus availableInputBus; /// 如果不存在返回 NSUIntegerMax
@property (nonatomic, readonly) GSAudioNodeBus availableOutputBus; /// 如果不存在返回 NSUIntegerMax
@end

NS_ASSUME_NONNULL_END
