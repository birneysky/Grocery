//
//  GSAudioOutputNode.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 Pea. All rights reserved.
//

#import "GSAudioOutputNode.h"
#import "GSAudioEngineStructures.h"
#import "GSAudioNode+Private.h"
#import "GSAudioUnit+Private.h"

static OSStatus renderInput(void *inRefCon,
                            AudioUnitRenderActionFlags *ioActionFlags,
                            const AudioTimeStamp *inTimeStamp,
                            UInt32 inBusNumber,
                            UInt32 inNumberFrames,
                            AudioBufferList *ioData) {
//    GSAudioNode* mixer = (__bridge GSAudioNode*)inRefCon;
//    AudioUnit unit = mixer.audioUnit.instance;
//    OSStatus result = AudioUnitRender(unit, ioActionFlags, inTimeStamp, 0, inNumberFrames, ioData);
//    NSLog(@"AudioUnitRender %@",@(result));
    //NSLog(@"renderInput inBusNumber:%@ inNumberFrames:%@",@(inBusNumber),@(inNumberFrames));
    for (UInt32 i=0; i<ioData->mNumberBuffers; ++i)
        memset(ioData->mBuffers[i].mData, 0, ioData->mBuffers[i].mDataByteSize);
    return noErr;
}


@interface GSAudioOutputNode() <GSAudioUnitDelegate>

@end

@implementation GSAudioOutputNode {
    GSAudioNode* _srcNode;
}

- (instancetype)initWithAudioUnit:(GSAudioUnit *)node {
    if (self = [super initWithAudioUnit:node]) {
        [self setAvailableInputBus:0];
        self.audioUnit.delegate = self;
        [self setup];
    }
    return self;
}

- (void)dealloc {
}

- (NSUInteger)numberOfInputs {
    return 1;
}

- (NSUInteger)numberOfOutputs {
    return 1;
}


- (GSAudioNodeBus)availableInputBus {
    return [super availableOutputBus];
}

- (GSAudioNodeBus)availableOutputBus {
    return InvalidAudioBus;
}

#pragma mark - Helper
- (void)setup {
    AudioUnit unit = [self audioUnit].instance;
    NSAssert(nil != unit, @"%@ %@ audio unit is nil",NSStringFromClass(self),NSStringFromSelector(_cmd));
    UInt32 enable_output = 1;
    OSStatus result = AudioUnitSetProperty(unit,
                                           kAudioOutputUnitProperty_EnableIO,
                                           kAudioUnitScope_Output,
                                           0,
                                           &enable_output,
                                           sizeof(enable_output));
    NSAssert(noErr == result, @"AudioUnitSetProperty kAudioOutputUnitProperty_EnableIO %@", @(result));
    
    AURenderCallbackStruct render_callback;
    render_callback.inputProc = renderInput;
    render_callback.inputProcRefCon = (__bridge void*)_srcNode;
    
    NSAssert(noErr == result, @"AudioUnitSetProperty kAudioOutputUnitProperty_EnableIO %@", @(result));
    
    result = AudioUnitSetProperty(unit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Input,
                                  0,
                                  &render_callback,
                                  sizeof(render_callback));
    NSAssert(noErr == result, @"AudioUnitSetProperty kAudioUnitProperty_SetRenderCallback %@", @(result));
    
}

#pragma mark - Private
- (void)associate:(GSAudioNode*)node {
    _srcNode = node;
    [self setAvailableInputBus:InvalidAudioBus];
    
    AudioUnit unit = [self audioUnit].instance;
    UInt32 enable_input = 1;
    OSStatus result = AudioUnitSetProperty(unit,
                                           kAudioOutputUnitProperty_EnableIO,
                                           kAudioUnitScope_Output,
                                           0,
                                           &enable_input,
                                           sizeof(enable_input));

}

#pragma mark - GSAudioUnitDelegate
- (void)didCreatedAudioUnitInstance {
    AudioUnit unit = [self audioUnit].instance;
    NSAssert(nil != unit, @"%@ %@ audio unit is nil",NSStringFromClass(self),NSStringFromSelector(_cmd));
    

    
  
    
    OSStatus result = AudioUnitAddRenderNotify(unit, &renderInput, unit);

    NSAssert(noErr == result, @"AudioUnitAddRenderNotify %@", @(result));

}

- (void)didFinishInitializing {
    
}

@end
