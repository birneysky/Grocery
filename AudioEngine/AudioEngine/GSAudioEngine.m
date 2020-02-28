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

@property (nonatomic,assign) BOOL isRunning;
@end

@implementation GSAudioEngine {
    AUGraph   _graph;
    AudioUnit mainMixer;
    AudioUnit output;
}

#pragma mark - Init
- (instancetype) init {
    if (self = [super init]) {
        OSStatus result = NewAUGraph(&_graph);
        NSAssert(noErr != result,@"NewAUGraph result %@",@(result));
    }
    return self;
}

- (void)dealloc {
    DisposeAUGraph(_graph);
}


#pragma mark - Apis
- (void)prepare {
    OSStatus result = AUGraphInitialize(_graph);
    if (noErr != result) {
        NSLog(@"AUGraphInitialize result %@", @(result));
    }
}
- (void)start {
    if (self.isRunning) {
        return;
    }
    
    OSStatus result = AUGraphStart(_graph);
    if (noErr != result) {
        NSLog(@"AUGraphStart result %@", @(result));
    }
    
}

- (void)stop {
    if (self.isRunning) {
        OSStatus result = AUGraphStop(_graph);
        if (noErr != result) {
            NSLog(@"AUGraphStop result %@\n", @(result));
        }
    }
}

- (BOOL)isRunning {
    return YES;
}

- (void)attach:(GSAudioNode*)node {
    
}

- (void)detach:(GSAudioNode*)node {
    
}


@end
