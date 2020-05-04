//
//  AUCallbacks.cpp
//  AudioEngineTests
//
//  Created by birney on 2020/5/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#include "AUCallbacks.hpp"
#include "AUQueuue.hpp"

OSStatus recordCallback1 (void *                            inRefCon,
                         AudioUnitRenderActionFlags *      ioActionFlags,
                         const AudioTimeStamp *            inTimeStamp,
                         UInt32                            inBusNumber,
                         UInt32                            inNumberFrames,
                         AudioBufferList * __nullable      ioData) {
    //NSLog(@"recordCallback1 bus:%@ audioFrames:%@, bufferList:%p", @(inBusNumber), @(inNumberFrames), ioData);
    AUCallbackRef* inRef = (AUCallbackRef*)inRefCon;
    if (inRef->m_firstInputSampleTime < 0) {
        inRef->m_firstInputSampleTime = inTimeStamp->mSampleTime;
        if (inRef->m_firstOutputSampleTime > 0 &&
            inRef->m_inToOutSampleTimeOffset < 0) {
            inRef->m_inToOutSampleTimeOffset = inRef->m_firstInputSampleTime - inRef->m_firstOutputSampleTime;
        }
    }
    AudioUnit unit = inRef->m_audioUnit;
    AudioBufferList audioData = {0};
    Byte buffer[4096] = {0};
    audioData.mNumberBuffers = 1;
    audioData.mBuffers[0].mData = buffer;
    audioData.mBuffers[0].mDataByteSize = inNumberFrames * 4;
    audioData.mBuffers[0].mNumberChannels = 1;
    OSStatus result = AudioUnitRender(unit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &audioData);
    assert(result == noErr);
    CARingBuffer* ringBuf = inRef->m_buffer;
    ringBuf->Store(&audioData, inNumberFrames, inTimeStamp->mSampleTime);
//    printf("=======================");
//    for (int i = 0; i < inNumberFrames * 4; ++ i) {
//        printf("%02x,", buffer[i]);
//    }
//    printf("\n=======================");
    return noErr;
}


OSStatus playoutCallback1 (void *                            inRefCon,
                         AudioUnitRenderActionFlags *      ioActionFlags,
                         const AudioTimeStamp *            inTimeStamp,
                         UInt32                            inBusNumber,
                         UInt32                            inNumberFrames,
                         AudioBufferList * __nullable      ioData) {
   // NSLog(@"recordCallback1 bus:%@ audioFrames:%@, bufferList:%p", @(inBusNumber), @(inNumberFrames), ioData);
    AUCallbackRef* inRef = (AUCallbackRef*)inRefCon;
    
    if (inRef->m_firstOutputSampleTime < 0) {
        inRef->m_firstOutputSampleTime = inTimeStamp->mSampleTime;
        if (inRef->m_firstInputSampleTime > 0 &&
            inRef->m_inToOutSampleTimeOffset < 0) {
            inRef->m_inToOutSampleTimeOffset = inRef->m_firstInputSampleTime - inRef->m_firstOutputSampleTime;
        }
    }
    //AudioUnit unit = inRef.m_audioUnit;
    CARingBuffer* ringBuf = inRef->m_buffer;
    AudioBufferList audioData = {0};
    Byte buffer[4096] = {0};
    audioData.mNumberBuffers = 1;
    audioData.mBuffers[0].mData = buffer;
    audioData.mBuffers[0].mDataByteSize = inNumberFrames * 4;
    audioData.mBuffers[0].mNumberChannels = 1;
    ringBuf->Fetch(ioData, inNumberFrames, inTimeStamp->mSampleTime + inRef->m_inToOutSampleTimeOffset);
//        printf("=======================");
//        for (int i = 0; i < inNumberFrames * 4; ++ i) {
//            printf("%02x,", buffer[i]);
//        }
//        printf("\n=======================");
    return noErr;
}


OSStatus playoutCallback2(void* _Nullable                      inRefCon,
                          AudioUnitRenderActionFlags* _Nonnull ioActionFlags,
                          const AudioTimeStamp* _Nonnull       inTimeStamp,
                          UInt32                               inBusNumber,
                          UInt32                               inNumberFrames,
                          AudioBufferList* __nullable          ioData) {
    AUQueue* queue = (AUQueue*)inRefCon;
    queue->Fetch(ioData, inNumberFrames, inTimeStamp->mSampleTime);
    return noErr;
}
