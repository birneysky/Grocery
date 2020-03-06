//
//  GSAudioOutputNode.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
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
    GSAudioNode* mixer = (__bridge GSAudioNode*)inRefCon;
    AudioUnit unit = mixer.audioUnit.instance;
    OSStatus result = AudioUnitRender(unit, ioActionFlags, inTimeStamp, 0, inNumberFrames, ioData);
    NSLog(@"AudioUnitRender %@",@(result));
    //NSLog(@"renderInput inBusNumber:%@ inNumberFrames:%@",@(inBusNumber),@(inNumberFrames));
//    for (UInt32 i=0; i<ioData->mNumberBuffers; ++i)
//        memset(ioData->mBuffers[i].mData, 0, ioData->mBuffers[i].mDataByteSize);
    return noErr;
}


@interface GSAudioOutputNode() <GSAudioUnitDelegate>

@end

@implementation GSAudioOutputNode {
    GSAudioNode* _srcNode;
}

//- (instancetype)init {
//    GSComponentDesc output_desc(kAudioUnitType_Output,
//                                kAudioUnitSubType_RemoteIO,
//                                kAudioUnitManufacturer_Apple);
//    if (self = [super initWithCommponenetDESC:output_desc]) {
//    }
//    return self;
//}

- (instancetype)initWithCommponenetDESC:(AudioComponentDescription)desc {
    if (self = [super initWithCommponenetDESC:desc]) {
        AudioComponentDescription voice_desc = self.audioUnit.acdesc;
        AudioComponent componenet = AudioComponentFindNext(nullptr, &voice_desc);
        OSStatus result = AudioComponentInstanceNew(componenet, &self.audioUnit.audioUnitRef);
         NSAssert(noErr == result, @"AudioComponentInstanceNew %@", @(result));

//        self.audioUnit.delegate = self;
        [self setup];
    }
    return self;
}

- (void)dealloc {
    AudioUnit unit = self.audioUnit.instance;
    OSStatus result = AudioComponentInstanceDispose(unit);
    NSAssert(noErr == result, @"AudioComponentInstanceDispose %@", @(result));
}

/// 扬声器的输入总线被禁用，所以应该为 0
- (NSUInteger)numberOfInputs {
    return 0;
}

/// 扬声器应该只有一条输出总线
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
    
}


- (void)start {
    AudioUnit unit = self.audioUnit.instance;
    OSStatus result = AudioOutputUnitStart(unit);
    NSAssert(noErr == result, @"AudioOutputUnitStart %@", @(result));
}

- (void)stop {
    AudioUnit vpio_unit = self.audioUnit.instance;
    OSStatus result = AudioOutputUnitStop(vpio_unit);
    NSAssert(noErr == result, @"AudioOutputUnitStart %@", @(result));
}

- (void)initialize {
    AudioUnit unit = [self audioUnit].instance;
    NSAssert(nil != unit, @"%@ %@ audio unit is nil",NSStringFromClass(self),NSStringFromSelector(_cmd));
    OSStatus result = AudioUnitInitialize(unit);
    NSAssert(noErr == result, @"AudioUnitInitialize %@", @(result));
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

#pragma mark - GSAudioUnitDelegate
- (void)didCreatedAudioUnitInstance {
    AudioUnit unit = [self audioUnit].instance;
    NSAssert(nil != unit, @"%@ %@ audio unit is nil",NSStringFromClass(self),NSStringFromSelector(_cmd));
    

    
  
    
    //OSStatus result = AudioUnitAddRenderNotify(unit, &renderInput, unit);

    

}

- (void)didFinishInitializing {
    
}

@end
