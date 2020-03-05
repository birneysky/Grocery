//
//  GSAudioPlayerNode.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "GSAudioPlayerNode.h"
#import "GSAudioEngineStructures.h"
#import "GSAudioUnit.h"
#import "GSAudioNode+Private.h"
#import "GSAudioMixing.h"
#import "GSMixingDestination.h"
#import "GSMixingVolumeControllable.h"

const GSAudioTimeStamp ValidStartAudioTime;
const UInt32 Indefinite = -1;

@interface GSAudioPlayerNode() <GSAudioUnitDelegate>

@property (nonatomic, readonly) UInt64 numberOfFrames;
@end



@implementation GSAudioPlayerNode {
    AudioFileID _audioFileID;
    ScheduledAudioFileRegion _region;
    AudioStreamBasicDescription _unitASBD;
    AudioStreamBasicDescription _fileASBD;
    UInt64 _audioPacketsCount;
    Float64 _sampleRateRatio;
    UInt32 _loopCount;
}

@synthesize inputVolume = _inputVolume;

#pragma mark - Api
- (instancetype)initWithFileURL:(NSURL*)fileURL {
    GSComponentDesc player_desc(kAudioUnitType_Generator,
                                kAudioUnitSubType_AudioFilePlayer,
                                kAudioUnitManufacturer_Apple);
    if (self = [super initWithCommponenetDESC:player_desc]) {
        self.audioUnit.delegate = self;
        OSStatus result =  AudioFileOpenURL((__bridge CFURLRef)fileURL,
                                            kAudioFileReadPermission,
                                            kAudioFileM4AType,
                                            &_audioFileID);
        NSAssert(noErr == result, @"AudioFileOpenURL %@", @(result));
        
        /// 获取音频包个数
        UInt32 propsize = sizeof(_audioPacketsCount);
        result = AudioFileGetProperty(_audioFileID,
                                      kAudioFilePropertyAudioDataPacketCount,
                                      &propsize,
                                      &_audioPacketsCount);
        NSAssert(noErr == result, @"AudioFileGetProperty  kAudioFilePropertyAudioDataPacketCount %@", @(result));

        /// 获取文件的 asbd
        propsize = sizeof(_fileASBD);
        result = AudioFileGetProperty(_audioFileID,
                                      kAudioFilePropertyDataFormat,
                                      &propsize, &_fileASBD);
        NSAssert(noErr == result, @"AudioFileGetProperty  kAudioFilePropertyDataFormat %@", @(result));
        _loopCount = 1;
    }
    return self;
}

- (void)play {
    [self scheduleStartTime: ValidStartAudioTime];
}

- (void)stop {
    [self reset];
    [self scheduleSegmentFrom:0 frameCount:self.numberOfFrames];
    [self scheduleStartTime:ValidStartAudioTime];
}

- (void)pause {
    AudioTimeStamp currentTime = [self currentPlayTime];
    [self reset];
    SInt64 start = (currentTime.mSampleTime) / _sampleRateRatio;
    UInt64 frameCount = self.numberOfFrames - start;
    [self scheduleSegmentFrom:start frameCount:frameCount];
    NSLog(@"GSAudioPlayerNode scheduleSegmentFrom:%@ ,framecount:%@ total:%@",
          @(start),@(frameCount),@(self.numberOfFrames));
}

- (BOOL)isPlaying {
    AudioUnit unit = [self audioUnit].instance;
    NSAssert(nil != unit, @"%@ %@ audio unit is nil",
             NSStringFromClass(self),NSStringFromSelector(_cmd));
    AudioTimeStamp currentPlayTime;
    UInt32 dataSize = sizeof(currentPlayTime);
    OSStatus result = AudioUnitGetProperty(unit,
                                           kAudioUnitProperty_CurrentPlayTime,
                                           kAudioUnitScope_Global,
                                           0,
                                           &currentPlayTime,
                                           &dataSize);
    if (noErr != result) {
        return NO;
    }
    return currentPlayTime.mSampleTime != -1.;
}

- (void)scheduleLoopCount:(NSUInteger)count {
    _loopCount = (UInt32)count;
}

#pragma mark - Helper
- (AudioTimeStamp)currentPlayTime {
    AudioUnit unit = [self audioUnit].instance;
    AudioTimeStamp currentPlayTime = {0};
    UInt32 dataSize = sizeof(currentPlayTime);
    OSStatus result = AudioUnitGetProperty(unit,
                                           kAudioUnitProperty_CurrentPlayTime,
                                           kAudioUnitScope_Global,
                                           0,
                                           &currentPlayTime,
                                           &dataSize);
    NSAssert(noErr == result,
             @"AudioUnitGetProperty kAudioUnitProperty_CurrentPlayTime %@",
             @(result));
    return currentPlayTime;
}

- (UInt64)numberOfFrames {
    return _audioPacketsCount * _fileASBD.mFramesPerPacket;;
}

- (void)reset {
    AudioUnit unit = [self audioUnit].instance;
    NSAssert(nil != unit, @"%@ %@ audio unit is nil",
             NSStringFromClass(self),NSStringFromSelector(_cmd));
    AudioUnitReset(unit, kAudioUnitScope_Global, 0);
}

- (void)scheduleSegmentFrom:(SInt64)startFrame frameCount:(UInt64)numberFrames {
    GSScheduledAudioFileRegion region(_audioFileID, startFrame, (UInt32)numberFrames, _loopCount);
    //_region = region;
    NSAssert(sizeof(GSScheduledAudioFileRegion) == sizeof(ScheduledAudioFileRegion), @"");
    AudioUnit unit = [self audioUnit].instance;
    NSAssert(nil != unit, @"%@ %@ audio unit is nil",
             NSStringFromClass(self),NSStringFromSelector(_cmd));
    OSStatus result = AudioUnitSetProperty(unit,
                                           kAudioUnitProperty_ScheduledFileRegion,
                                           kAudioUnitScope_Global,
                                           0,
                                           &region,
                                           sizeof(region));
    NSAssert(noErr == result,
             @"AudioUnitSetProperty kAudioUnitProperty_ScheduledFileRegion %@",
             @(result));
}

- (void)scheduleStartTime:(AudioTimeStamp)time {
    AudioUnit unit = [self audioUnit].instance;
    NSAssert(nil != unit, @"%@ %@ audio unit is nil",
             NSStringFromClass(self),NSStringFromSelector(_cmd));
    OSStatus result = AudioUnitSetProperty(unit,
                                           kAudioUnitProperty_ScheduleStartTimeStamp,
                                           kAudioUnitScope_Global,
                                           0,
                                           &time,
                                           sizeof(time));
    NSAssert(noErr == result,
             @"AudioUnitSetProperty kAudioUnitProperty_ScheduleStartTimeStamp %@",
             @(result));
}

#pragma mark - GSAudioUnitDelegate
- (void)didCreatedAudioUnitInstance {
    AudioUnit unit = [self audioUnit].instance;
    NSAssert(nil != unit, @"%@ %@ audio unit is nil",
             NSStringFromClass(self),NSStringFromSelector(_cmd));
    OSStatus result = AudioUnitSetProperty(unit,
                                           kAudioUnitProperty_ScheduledFileIDs,
                                           kAudioUnitScope_Global,
                                           0, &_audioFileID,
                                           sizeof(AudioFileID));
    NSAssert(noErr == result, @"AudioUnitSetProperty kAudioUnitProperty_ScheduledFileIDs %@", @(result));

    
    UInt32 propsize = sizeof(_fileASBD);
    AudioUnitGetProperty(unit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Output,
                         0,
                         &_unitASBD,
                         &propsize);

    if (_fileASBD.mSampleRate > 0 && _unitASBD.mSampleRate > 0) {
        _sampleRateRatio = _unitASBD.mSampleRate / _fileASBD.mSampleRate;
    } else {
        _sampleRateRatio = 1.;
    }
}

#pragma mark - GSAudioMixing
- (void)setInputVolume:(float)volume {
    _inputVolume = volume;
    GSMixingDestination* dst = [self.delegate mixingDestinationOfNode:self];
    [dst.node setInputVolume:volume inputBus:dst.bus];
}

#pragma mark - override
- (void)didFinishInitializing{
    [self scheduleSegmentFrom:0 frameCount:self.numberOfFrames];
    [self scheduleStartTime:ValidStartAudioTime];
}

@end
