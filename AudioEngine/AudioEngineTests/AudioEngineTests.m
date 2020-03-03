//
//  AudioEngineTests.m
//  AudioEngineTests
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GSAudioOutputNode.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>

@interface AudioEngineTests : XCTestCase

@end

@implementation AudioEngineTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    GSAudioOutputNode* node = [[GSAudioOutputNode alloc] init];
}

- (void)testAudioUnitFile {
    AudioStreamBasicDescription inputFormat;
    AudioFileID inputFile;
    AUGraph graph;
    AudioUnit fileAU;
    
    NSBundle* currentBuldle = [NSBundle bundleForClass:AudioEngineTests.class];
    NSString* audioFilePath = [currentBuldle pathForResource:@"Synth" ofType:@"aif"];
    NSURL* fileURL = [NSURL fileURLWithPath:audioFilePath];
    OSStatus result =  AudioFileOpenURL((__bridge CFURLRef)fileURL,
                                        kAudioFileReadPermission,
                                        kAudioFileAIFFType,
                                        &inputFile);
    NSAssert(noErr == result, @"AudioFileOpenURL %@", @(result));

    UInt32 propSize = sizeof(inputFormat);
    result = AudioFileGetProperty(inputFile,
                                  kAudioFilePropertyDataFormat,
                                  &propSize,
                                  &inputFormat);
    NSAssert(noErr == result, @"AudioFileGetProperty kAudioFilePropertyDataFormat %@", @(result));
    
    
    result = NewAUGraph(&graph);
    NSAssert(noErr == result,@"NewAUGraph %@",@(result));

    
    AudioComponentDescription outputcd = {0};
    outputcd.componentType = kAudioUnitType_Output;
    outputcd.componentSubType = kAudioUnitSubType_RemoteIO;
    outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    AUNode outputNode;
    result = AUGraphAddNode(graph, &outputcd, &outputNode);
    NSAssert(noErr == result,@"AUGraphAddNode %@",@(result));
    
    AudioComponentDescription fileplayercd = {0};
    fileplayercd.componentType = kAudioUnitType_Generator;
    fileplayercd.componentSubType = kAudioUnitSubType_AudioFilePlayer;
    fileplayercd.componentManufacturer = kAudioUnitManufacturer_Apple;
    AUNode fileNode;
    result = AUGraphAddNode(graph, &fileplayercd, &fileNode);
    NSAssert(noErr == result,@"AUGraphAddNode %@",@(result));
    
    result = AUGraphOpen(graph);
    NSAssert(noErr == result,@"AUGraphOpen %@",@(result));
    
    result = AUGraphNodeInfo(graph,fileNode, NULL, &fileAU);
    NSAssert(noErr == result,@"AUGraphNodeInfo %@",@(result));
    
    result = AUGraphConnectNodeInput(graph, fileNode, 0, outputNode, 0);
    NSAssert(noErr == result,@"AUGraphConnectNodeInput %@",@(result));
    
    result = AUGraphInitialize(graph);
    NSAssert(noErr == result,@"AUGraphInitialize %@",@(result));
    
    
    result = AudioUnitSetProperty(fileAU,
                                  kAudioUnitProperty_ScheduledFileIDs,
                                  kAudioUnitScope_Global,
                                  0,
                                  &inputFile,
                                  sizeof(inputFile));
    NSAssert(noErr == result,@"AudioUnitSetProperty kAudioUnitProperty_ScheduledFileIDs %@",@(result));
    
    
    UInt64 nPackets;
    UInt32 propsize = sizeof(nPackets);
    result = AudioFileGetProperty(inputFile,
                                  kAudioFilePropertyAudioDataPacketCount, &propsize,
                                  &nPackets);
    NSAssert(noErr == result,@"AudioFileGetProperty kAudioFilePropertyAudioDataPacketCount %@",@(result));
    
    ScheduledAudioFileRegion rgn;
    memset (&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
    rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
    rgn.mTimeStamp.mSampleTime = 0;
    rgn.mCompletionProc = NULL;
    rgn.mCompletionProcUserData = NULL;
    rgn.mAudioFile = inputFile;
    
    rgn.mLoopCount = 2;
    rgn.mStartFrame = 0;
    rgn.mFramesToPlay = (UInt32)nPackets * inputFormat.mFramesPerPacket;
    
    result = AudioUnitSetProperty(fileAU, kAudioUnitProperty_ScheduledFileRegion,
                                  kAudioUnitScope_Global, 0,
                                  &rgn,
                                  sizeof(rgn));
    NSAssert(noErr == result,@"AudioUnitSetProperty kAudioUnitProperty_ScheduledFileRegion %@",@(result));
    
    AudioTimeStamp startTime;
    memset (&startTime, 0, sizeof(startTime));
    startTime.mFlags = kAudioTimeStampSampleTimeValid; startTime.mSampleTime = -1;

    result = AudioUnitSetProperty(fileAU, kAudioUnitProperty_ScheduleStartTimeStamp,
                                  kAudioUnitScope_Global, 0,
                                  &startTime,
                                  sizeof(startTime));
    NSAssert(noErr == result,@"AudioUnitSetProperty kAudioUnitProperty_ScheduleStartTimeStamp %@",@(result));
    
    /// Calculating File Playback Time in Seconds
    NSInteger duration =  nPackets * inputFormat.mFramesPerPacket / inputFormat.mSampleRate;
    
    result = AUGraphStart(graph);
    NSLog(@"start playing duration %@ s", @(duration));
    usleep ((int)(duration * 1000.0 * 1000.0) * rgn.mLoopCount);
    NSLog(@"stop play");
    AUGraphStop(graph);
    AUGraphUninitialize(graph);
    AUGraphClose(graph);
    AudioFileClose(inputFile);

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
