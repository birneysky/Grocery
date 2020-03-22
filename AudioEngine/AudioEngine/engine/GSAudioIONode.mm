//
//  GSAudioIONode.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 Pea. All rights reserved.
//

#import "GSAudioIONode.h"
#import "GSAudioNode+Private.h"
#import "GSAudioUnit+Private.h"

@implementation GSAudioIONode

- (instancetype)initWithAudioUnit:(GSAudioUnit *)node {
    if (self = [super initWithAudioUnit:node]) {
        //[self disableIO];
    }
    return self;
}

- (void)disableIO{
    AudioUnit unit = [self audioUnit].instance;
    if (!unit) {
        return;
    }
    OSStatus result = noErr;
    const UInt32 disable = 0;
    result = AudioUnitSetProperty(unit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  0,
                                  &disable,
                                  sizeof(disable));
    NSAssert(noErr == result, @"AudioUnitSetProperty kAudioOutputUnitProperty_EnableIO %@", @(result));
    result = AudioUnitSetProperty(unit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  1,
                                  &disable,
                                  sizeof(disable));
    NSAssert(noErr == result, @"AudioUnitSetProperty kAudioOutputUnitProperty_EnableIO %@", @(result));
}


@end
