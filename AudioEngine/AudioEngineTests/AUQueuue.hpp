//
//  AUQueuue.hpp
//  AudioEngineTests
//
//  Created by birney on 2020/5/3.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#ifndef AUQueuue_hpp
#define AUQueuue_hpp

#import <AudioUnit/AudioUnit.h>
#include "CARingBuffer.h"

class AUQueue {
private:
    CARingBuffer m_buffer;
    Float64 m_firstInputSampleTime;
    Float64 m_firstOutputSampleTime;
    Float64 m_inToOutSampleTimeOffset;
    const UInt32 bufferCapacity = 4096;
    AudioStreamBasicDescription m_asbd;
    bool m_quit;
    pthread_mutex_t m_bufferLock;
    pthread_cond_t  m_bufferCondition;
public:
    AUQueue (const AudioStreamBasicDescription& asbd);
    ~AUQueue();
    void Store(const AudioBufferList *abl, UInt32 nFrames, SInt64 sampleTime);
    void Fetch(AudioBufferList *abl, UInt32 nFrames, SInt64 sampleTime);
};

#endif /* AUQueuue_hpp */
