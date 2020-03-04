//
//  GSAudioNode.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "GSAudioNode.h"
#import "GSAudioUnit.h"

@interface GSAudioNode () <GSAudioUnitDelegate>

@property (nonatomic,strong) GSAudioUnit* audioUnit;
@property (nonatomic, assign) AUNode node;

@end

@implementation GSAudioNode {
    GSAudioUnit* _audioUnit;
    AUNode _node;
    GSAudioNodeBus _availableInputBus; /// 可用 input bus 的索引
    GSAudioNodeBus _availableOutputBus; /// 可用 input bus 的索引
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
                                  kAudioUnitScope_Input, 0, &numbuses, &propSize);
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
                                  kAudioUnitScope_Output, 0, &numbuses, &propSize);
    NSAssert(noErr == result, @"AudioUnitGetProperty kAudioUnitProperty_ElementCount kAudioUnitScope_Input %@",@(result));
    return numbuses;
}


- (NSUInteger)availableInputBus {
    return _availableInputBus;
}

- (NSUInteger)availableOutputBus {
    return _availableOutputBus;
}

#pragma mark - notification
- (void)didFinishInitializing{
   // do nothing
}

- (void)didConnectedNodeInputBus:(GSAudioNodeBus)bus {
    if (bus == self.numberOfInputs - 1) {
        _availableInputBus = NSUIntegerMax;
        return;
    }
    _availableInputBus += 1;
}

- (void)didConnectedNodeOutputBus:(GSAudioNodeBus)bus {
    if (bus == self.numberOfOutputs - 1) {
        _availableOutputBus = NSUIntegerMax;
        return;
    }
    _availableOutputBus += 1;
}

@end
