//
//  AUCallbacks.hpp
//  AudioEngineTests
//
//  Created by birney on 2020/5/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#ifndef AUCallbacks_hpp
#define AUCallbacks_hpp
#import <AudioUnit/AudioUnit.h>
#include "CARingBuffer.h"

NS_ASSUME_NONNULL_BEGIN
struct AUCallbackRef {
    AudioUnit m_audioUnit;
    CARingBuffer* m_buffer;
    Float64 m_firstInputSampleTime;
    Float64 m_firstOutputSampleTime;
    Float64 m_inToOutSampleTimeOffset;
    AUCallbackRef(AudioUnit unit, CARingBuffer* buffer) {
        m_audioUnit = unit;
        m_buffer = buffer;
        m_firstInputSampleTime = -1;
        m_firstOutputSampleTime = -1;
        m_inToOutSampleTimeOffset = -1;
    }
    
    ~AUCallbackRef() {
    }
};

OSStatus recordCallback1(void* _Nullable                      inRefCon,
                         AudioUnitRenderActionFlags* _Nonnull ioActionFlags,
                         const AudioTimeStamp* _Nonnull       inTimeStamp,
                         UInt32                               inBusNumber,
                         UInt32                               inNumberFrames,
                         AudioBufferList* __nullable          ioData);


OSStatus playoutCallback1(void* _Nullable                      inRefCon,
                          AudioUnitRenderActionFlags* _Nonnull ioActionFlags,
                          const AudioTimeStamp* _Nonnull       inTimeStamp,
                          UInt32                               inBusNumber,
                          UInt32                               inNumberFrames,
                          AudioBufferList* __nullable          ioData);

OSStatus playoutCallback2(void* _Nullable                      inRefCon,
                          AudioUnitRenderActionFlags* _Nonnull ioActionFlags,
                          const AudioTimeStamp* _Nonnull       inTimeStamp,
                          UInt32                               inBusNumber,
                          UInt32                               inNumberFrames,
                          AudioBufferList* __nullable          ioData);


NS_ASSUME_NONNULL_END
#endif /* AUCallbacks_hpp */

