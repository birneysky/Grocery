//
//  GSAudioEngine.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "GSAudioEngine.h"

@interface GSAudioEngine()

@end

@implementation GSAudioEngine {
    AUGraph   _graph;
    AudioUnit mainMixer;
    AudioUnit output;
}

@end
