//
//  GSAudioMixerNode.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <AudioUnit/AudioUnit.h>
#import "GSAudioMixerNode.h"
#import "GSAudioEngineStructures.h"
#import "GSAudioUnit.h"
#import "GSAudioNode+Private.h"

@interface GSAudioMixerNode () <GSAudioUnitDelegate>

@end

@implementation GSAudioMixerNode

- (instancetype)init {
    GSComponentDesc mixer_desc(kAudioUnitType_Mixer,
                                      kAudioUnitSubType_MultiChannelMixer,
                                      kAudioUnitManufacturer_Apple);
    if (self = [super initWithCommponenetDESC:mixer_desc]) {
        self.audioUnit.delegate = self;
    }
    return self;
}


#pragma mark - GSAudioUnitDelegate
- (void)didcreatedAudioUnitInstance {
    AudioUnit unit = [self audioUnit].instance;
    NSAssert(nil != unit, @"%@ %@ audio unit is nil",NSStringFromClass(self),NSStringFromSelector(_cmd));
    const UInt32 numbuses = 2;
    OSStatus result = AudioUnitSetProperty(unit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numbuses, sizeof(numbuses));
    NSAssert(noErr == result, @"AudioUnitSetProperty kAudioUnitProperty_ElementCount %@", @(result));
}

@end
