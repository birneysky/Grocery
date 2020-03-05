//
//  GSAudioNode.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "GSAudioNode.h"
#import "GSAudioUnit.h"

@protocol GSAudioNodeDelegate;

@interface GSAudioNode () <GSAudioUnitDelegate>

@property (nonatomic,strong) GSAudioUnit* audioUnit;
@property (nonatomic, assign) AUNode node;
@property (nonatomic, weak) id<GSAudioNodeDelegate> delegate;
@end

const GSAudioNodeBus InvalidAudioBus = UINT32_MAX;

@implementation GSAudioNode {
    GSAudioUnit* _audioUnit;
    AUNode _node;
    GSAudioNodeBus _availableInputBus; /// 当前可用 input bus 的索引
    GSAudioNodeBus _availableOutputBus; /// 当前可用 input bus 的索引
}

- (instancetype)initWithCommponenetDESC:(AudioComponentDescription)desc {
    if (self = [super init]) {
        _audioUnit = [[GSAudioUnit alloc] initWithComponentDescription:desc];
    }
    return self;
}

- (void)setAUNode:(AUNode)node {
    _node = node;
}

- (GSAudioUnit*)audioUnit  {
    return _audioUnit;
}

- (AUNode)node {
    return _node;
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
                                            0,
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


- (GSAudioNodeBus)availableInputBus {
    return _availableInputBus;
}

- (GSAudioNodeBus)availableOutputBus {
    return _availableOutputBus;
}

#pragma mark - notification
- (void)didFinishInitializing{
   // do nothing
}

- (void)addConnectedInputBus:(GSAudioNodeBus)bus {
    if (bus == self.numberOfInputs - 1) {
        _availableInputBus = UINT32_MAX;
        return;
    }
    _availableInputBus += 1;
}

- (void)addConnectedOutputBus:(GSAudioNodeBus)bus {
    if (bus == self.numberOfOutputs - 1) {
        _availableOutputBus = UINT32_MAX;
        return;
    }
    _availableOutputBus += 1;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return self;
}

@end
