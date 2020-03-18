//
//  GSAudioInputNode.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 Pea. All rights reserved.
//

#import "GSAudioInputNode.h"
#import "GSAudioEngineStructures.h"
#import "GSAudioNode+Private.h"
#import "GSAudioUnit+Private.h"


static OSStatus renderInput(void *inRefCon,
                            AudioUnitRenderActionFlags *ioActionFlags,
                            const AudioTimeStamp *inTimeStamp,
                            UInt32 inBusNumber,
                            UInt32 inNumberFrames,
                            AudioBufferList *ioData) {
    AudioUnit vpio_unit  = (AudioUnit)inRefCon;
//    AudioBufferList list;
//    list.mNumberBuffers = 1;
//    list.mBuffers[0].mData = malloc(inNumberFrames * 4);
//    list.mBuffers[0].mNumberChannels = 1;
//    list.mBuffers[0].mDataByteSize = inNumberFrames * 4;
//    OSStatus result = AudioUnitRender(vpio_unit, ioActionFlags, inTimeStamp, 1, inNumberFrames, &list);
//    //NSAssert(noErr == result, @"AudioUnitRender %@", @(result));
//    AudioBuffer buffer = ioData->mBuffers[0];
//    NSData* data = [NSData dataWithBytes:buffer.mData length:buffer.mDataByteSize];
//    NSLog(@"channel:%@,%@", @(buffer.mNumberChannels), data);
    return noErr;
}

@implementation GSAudioInputNode

- (instancetype)initWithAudioUnit:(GSAudioUnit *)node {
    if (self = [super initWithAudioUnit:node]) {
        [self setAvailableOutputBus:1];
        [self setup];
    }
    return self;
}


- (NSUInteger)numberOfInputs {
    return 1;
}

- (NSUInteger)numberOfOutputs {
    return 1;
}

- (GSAudioNodeBus)availableInputBus {
    return InvalidAudioBus;
}

- (GSAudioNodeBus)availableOutputBus {
    return [super availableOutputBus];
}

- (void)addConnectedOutputBus:(GSAudioNodeBus)bus {
    self.availableOutputBus = InvalidAudioBus;
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
    
    
    GSAudioStreamBasicDesc asbd(48000, 1, GSAudioStreamBasicDesc::kPCMFormatFloat32, false);
    UInt32 size = sizeof(asbd);
    result = AudioUnitSetProperty(vpio_unit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  1, &asbd, size);
    NSAssert(noErr == result, @"AudioUnitSetProperty kAudioUnitProperty_StreamFormat %@", @(result));
    
    const Float64 sampleRate = 48000;
    result = AudioUnitSetProperty(vpio_unit,
                                  kAudioUnitProperty_SampleRate,
                                  kAudioUnitScope_Output,
                                  1,
                                  &sampleRate,
                                  sizeof(Float64));
    NSAssert(noErr == result, @"AudioUnitSetProperty kAudioUnitProperty_SampleRate %@", @(result));
//    
    AURenderCallbackStruct render_callback;
    render_callback.inputProc = renderInput;
    render_callback.inputProcRefCon = vpio_unit;
        
        
    result = AudioUnitSetProperty(vpio_unit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  1,
                                  &render_callback,
                                  sizeof(render_callback));
    NSAssert(noErr == result, @"AudioUnitSetProperty kAudioUnitProperty_SetRenderCallback %@", @(result));
}

- (void)dealloc {

}

@end
