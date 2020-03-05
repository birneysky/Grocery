//
//  GSAudioInputNode.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "GSAudioInputNode.h"
#import "GSAudioEngineStructures.h"
#import "GSAudioNode+Private.h"
#import "GSAudioUnit+Private.h"

@implementation GSAudioInputNode 

- (instancetype)initWithCommponenetDESC:(AudioComponentDescription)desc {
    if (self = [super initWithCommponenetDESC:desc]) {
        AudioComponentDescription voice_desc = self.audioUnit.acdesc;
        AudioComponent componenet = AudioComponentFindNext(nullptr, &voice_desc);
        OSStatus result = AudioComponentInstanceNew(componenet, &self.audioUnit.audioUnitRef);
         NSAssert(noErr == result, @"AudioComponentInstanceNew %@", @(result));
        [self setup];
    }
    return self;
}

- (void)setup {
    AudioUnit vpio_unit = self.audioUnit.instance;
    const UInt32 enable = 1;
    const AudioUnitElement inputBus = 1;
    OSStatus result = AudioUnitSetProperty(vpio_unit,
                                           kAudioOutputUnitProperty_EnableIO,
                                           kAudioUnitScope_Input,
                                           inputBus,
                                           &enable,
                                           sizeof(enable));
    NSAssert(noErr == result, @"AudioUnitSetProperty kAudioOutputUnitProperty_EnableIO %@", @(result));
    
    result = AudioUnitInitialize(vpio_unit);
    NSAssert(noErr == result, @"AudioUnitInitialize %@", @(result));
}

- (void)start {
    AudioUnit vpio_unit = self.audioUnit.instance;
    OSStatus result = AudioOutputUnitStart(vpio_unit);
    NSAssert(noErr == result, @"AudioOutputUnitStart %@", @(result));
}

- (void)stop {
    AudioUnit vpio_unit = self.audioUnit.instance;
    OSStatus result = AudioOutputUnitStop(vpio_unit);
    NSAssert(noErr == result, @"AudioOutputUnitStart %@", @(result));
}

- (void)dealloc {
    AudioUnit vpio_unit = self.audioUnit.instance;
    OSStatus result = AudioComponentInstanceDispose(vpio_unit);
    NSAssert(noErr == result, @"AudioComponentInstanceDispose %@", @(result));
}

@end
