//
//  GSAudioMixerNode.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <AudioUnit/AudioUnit.h>
#import "GSAudioMixerNode.h"
#import "GSComponentDescription.h"
#import "GSAudioUnit.h"

@interface GSAudioMixerNode ()

@property (nonatomic, strong) GSAudioUnit* audioUnit;

@end

@implementation GSAudioMixerNode
@synthesize audioUnit = _audioUnit;

- (instancetype)init {
    if (self = [super init]) {
        GSComponentDescription mixer_desc(kAudioUnitType_Mixer,
                                          kAudioUnitSubType_MultiChannelMixer,
                                          kAudioUnitManufacturer_Apple);
        _audioUnit = [[GSAudioUnit alloc] initWithComponentDescription:mixer_desc];
    }
    return self;
}

- (GSAudioUnit*)audioUnit  {
    return _audioUnit;
}

@end
