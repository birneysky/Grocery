//
//  AUCallbacks.cpp
//  AudioEngineTests
//
//  Created by birney on 2020/5/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#include "AUCallbacks.hpp"


OSStatus recordCallback1 (void *                            inRefCon,
                         AudioUnitRenderActionFlags *      ioActionFlags,
                         const AudioTimeStamp *            inTimeStamp,
                         UInt32                            inBusNumber,
                         UInt32                            inNumberFrames,
                         AudioBufferList * __nullable      ioData) {
    NSLog(@"recordCallback1 bus:%@ audioFrames:%@, bufferList:%p", @(inBusNumber), @(inNumberFrames), ioData);
    AudioUnit unit = (AudioUnit)inRefCon;
    AudioBufferList audioData = {0};
    Byte buffer[4096] = {0};
    audioData.mNumberBuffers = 1;
    audioData.mBuffers[0].mData = buffer;
    audioData.mBuffers[0].mDataByteSize = inNumberFrames * 4;
    audioData.mBuffers[0].mNumberChannels = 1;
    OSStatus result = AudioUnitRender(unit, ioActionFlags, inTimeStamp, 0, inNumberFrames, &audioData);
    assert(result == noErr);
//    memcpy(ioData->mBuffers[0].mData, buffer, inNumberFrames*4);
    return noErr;
}


OSStatus playoutCallback1 (void *                            inRefCon,
                         AudioUnitRenderActionFlags *      ioActionFlags,
                         const AudioTimeStamp *            inTimeStamp,
                         UInt32                            inBusNumber,
                         UInt32                            inNumberFrames,
                         AudioBufferList * __nullable      ioData) {
    NSLog(@"recordCallback1 bus:%@ audioFrames:%@, bufferList:%p", @(inBusNumber), @(inNumberFrames), ioData);
    AudioUnit unit = (AudioUnit)inRefCon;
    AudioBufferList audioData = {0};
    Byte buffer[4096] = {0};
    audioData.mNumberBuffers = 1;
    audioData.mBuffers[0].mData = buffer;
    audioData.mBuffers[0].mDataByteSize = inNumberFrames * 4;
    audioData.mBuffers[0].mNumberChannels = 1;
    OSStatus result = AudioUnitRender(unit, ioActionFlags, inTimeStamp, 0, inNumberFrames, &audioData);
    assert(result == noErr);
//    memcpy(ioData->mBuffers[0].mData, buffer, inNumberFrames*4);
    return noErr;
}
