//
//  AUQueuue.cpp
//  AudioEngineTests
//
//  Created by birney on 2020/5/3.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#include "AUQueuue.hpp"
#include <iostream>
#include <pthread.h>

AUQueue::AUQueue(const AudioStreamBasicDescription& asbd) {
    m_firstInputSampleTime = -1;
    m_firstOutputSampleTime = -1;
    m_inToOutSampleTimeOffset = -1;
    m_asbd = asbd;
    m_quit = false;
    m_buffer.Allocate(asbd.mChannelsPerFrame, asbd.mBytesPerFrame, 16384/*asbd.mSampleRate*/);
    pthread_mutex_init(&m_bufferLock, NULL);
    pthread_cond_init(&m_bufferCondition, NULL);
}

void AUQueue::Store(const AudioBufferList *abl, UInt32 nFrames, SInt64 sampleTime) {
    if (m_firstInputSampleTime < 0) {
        m_firstInputSampleTime = sampleTime;
        if (m_firstOutputSampleTime >= 0 && m_inToOutSampleTimeOffset < 0) {
              m_inToOutSampleTimeOffset = m_firstInputSampleTime - m_firstOutputSampleTime;
          }
    }
    pthread_mutex_lock(&m_bufferLock);
    while (!m_buffer.CanStore(nFrames) && !m_quit) {
        pthread_cond_wait(&m_bufferCondition, &m_bufferLock);
    }
    if (!m_quit) {
        m_buffer.Store(abl, nFrames, sampleTime);
    } else {
        std::cout << "store ignore" << std::endl;
    }
    pthread_mutex_unlock(&m_bufferLock);
}

void AUQueue::Fetch(AudioBufferList *abl, UInt32 nFrames, SInt64 sampleTime) {
    if (m_firstOutputSampleTime < 0) {
        m_firstOutputSampleTime = sampleTime;
        if (m_firstInputSampleTime >= 0 && m_inToOutSampleTimeOffset < 0) {
            m_inToOutSampleTimeOffset = m_firstInputSampleTime - m_firstOutputSampleTime;
        }
    }
    pthread_mutex_lock(&m_bufferLock);
    m_buffer.Fetch(abl, nFrames, sampleTime + m_inToOutSampleTimeOffset);
    pthread_cond_signal(&m_bufferCondition);
    pthread_mutex_unlock(&m_bufferLock);
}

AUQueue::~AUQueue() {
    pthread_mutex_lock(&m_bufferLock);
    m_quit = true;
    pthread_cond_signal(&m_bufferCondition);
    pthread_mutex_unlock(&m_bufferLock);
    m_buffer.Deallocate();
    pthread_mutex_destroy(&m_bufferLock);
    pthread_cond_destroy(&m_bufferCondition);
}
