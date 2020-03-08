//
//  GSAudioNode.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 Pea. All rights reserved.
//

#import "GSAudioNode.h"
#import "GSAudioUnit.h"
#import <AVFoundation/AVFoundation.h>

@protocol GSAudioNodeDelegate;

@interface GSAudioNode () <GSAudioUnitDelegate>

@property (nonatomic,strong) GSAudioUnit* audioUnit;
@property (nonatomic, assign) AUNode node;
@property (nonatomic, weak) id<GSAudioNodeDelegate> delegate;
@end

const GSAudioNodeBus InvalidAudioBus = UINT32_MAX;

@implementation GSAudioNode {
    GSAudioUnit* _audioUnit;
    GSAudioNodeBus _availableInputBus; /// 当前可用 input bus 的索引
    GSAudioNodeBus _availableOutputBus; /// 当前可用 input bus 的索引
}

- (instancetype)initWithCommponenetDESC:(AudioComponentDescription)desc {
    if (self = [super init]) {
        _audioUnit = [[GSAudioUnit alloc] initWithComponentDescription:desc];
    }
    return self;
}

- (instancetype)initWithAudioUnit:(GSAudioUnit*)node {
    if (self = [super init]) {
        _audioUnit = node;
    }
    return self;
}

- (GSAudioUnit*)audioUnit  {
    return _audioUnit;
}

- (NSUInteger)numberOfInputs {
    if (!_audioUnit.instance) {
        return 0;
    }
    UInt32 numbuses = 0;
    UInt32 propSize = sizeof(numbuses);
    OSStatus  result = AudioUnitGetProperty(_audioUnit.instance,
                                            kAudioUnitProperty_ElementCount,
                                            kAudioUnitScope_Input,
                                            1,
                                            &numbuses,
                                            &propSize);
    NSAssert(noErr == result, @"AudioUnitGetProperty kAudioUnitProperty_ElementCount kAudioUnitScope_Input %@",@(result));
    return numbuses;
}

- (NSUInteger)numberOfOutputs {
    if (!_audioUnit.instance) {
        return 0;
    }
    UInt32 numbuses = 0;
    UInt32 propSize = sizeof(numbuses);
    OSStatus  result = AudioUnitGetProperty(_audioUnit.instance,
                                            kAudioUnitProperty_ElementCount,
                                            kAudioUnitScope_Output,
                                            0,
                                            &numbuses,
                                            &propSize);
    NSAssert(noErr == result, @"AudioUnitGetProperty kAudioUnitProperty_ElementCount kAudioUnitScope_Input %@",@(result));
    return numbuses;
}

- (AVAudioFormat *)inputFormatForBus:(GSAudioNodeBus)bus {
    if (!_audioUnit.instance) {
         return 0;
     }
    AudioStreamBasicDescription asbd = {0};
     UInt32 propSize = sizeof(AudioStreamBasicDescription);
     OSStatus  result = AudioUnitGetProperty(_audioUnit.instance,
                                             kAudioUnitProperty_StreamFormat,
                                             kAudioUnitScope_Input,
                                             bus,
                                             &asbd,
                                             &propSize);
     NSAssert(noErr == result, @"AudioUnitGetProperty kAudioUnitProperty_StreamFormat kAudioUnitScope_Input %@",@(result));
     return [[AVAudioFormat alloc] initWithStreamDescription:&asbd];
}

- (AVAudioFormat *)outputFormatForBus:(GSAudioNodeBus)bus {
    if (!_audioUnit.instance) {
         return 0;
     }
      AudioStreamBasicDescription asbd = {0};
     UInt32 propSize = sizeof(AudioStreamBasicDescription);
     OSStatus  result = AudioUnitGetProperty(_audioUnit.instance,
                                             kAudioUnitProperty_StreamFormat,
                                             kAudioUnitScope_Output,
                                             bus,
                                             &asbd,
                                             &propSize);
     NSAssert(noErr == result, @"AudioUnitGetProperty kAudioUnitProperty_StreamFormat kAudioUnitScope_Input %@",@(result));
     return [[AVAudioFormat alloc] initWithStreamDescription:&asbd];
}


- (GSAudioNodeBus)availableInputBus {
    return _availableInputBus;
}

- (GSAudioNodeBus)availableOutputBus {
    return _availableOutputBus;
}

- (void)setAvailableInputBus:(GSAudioNodeBus)availableInputBus {
    _availableInputBus = availableInputBus;
}

- (void)setAvailableOutputBus:(GSAudioNodeBus)availableOutputBus {
    _availableOutputBus = availableOutputBus;
}

#pragma mark - notification
- (void)didFinishInitializing{
   // do nothing
}

- (void)addConnectedInputBus:(GSAudioNodeBus)bus {
    const NSUInteger numberOfInputs = self.numberOfInputs;
    if (bus == numberOfInputs - 1) {
        _availableInputBus = InvalidAudioBus;
        return;
    }
    _availableInputBus += 1;
}

- (void)addConnectedOutputBus:(GSAudioNodeBus)bus {
    const NSUInteger numberOfInputs = self.numberOfOutputs;
    if (bus == numberOfInputs - 1) {
        _availableOutputBus = InvalidAudioBus;
        return;
    }
    _availableOutputBus += 1;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return self;
}

@end
