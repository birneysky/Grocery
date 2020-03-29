//
//  AudioEngineTests.m
//  AudioEngineTests
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 Pea. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import "GSAudioOutputNode.h"
#import "GSAudioEngine.h"
#import "GSAudioInputNode.h"
#import "GSAudioMixerNode.h"
#import "AudioData.h"
#import "GSAudioEngineStructures.h"

void printASBD(const struct AudioStreamBasicDescription asbd) {
 
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
 
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10X",    asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10d",    asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10d",    asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10d",    asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10d",    asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10d",    asbd.mBitsPerChannel);
}

OSStatus inputDataProc (  AudioConverterRef               inAudioConverter,
                                        UInt32 *                        ioNumberDataPackets,
                                        AudioBufferList *               ioData,
                                        AudioStreamPacketDescription * __nullable * __nullable outDataPacketDescription,
                                             void * __nullable               inUserData) {
    
    AudioBufferList* inputList = (AudioBufferList*)inUserData;
    ioData->mNumberBuffers = 1;
    ioData->mBuffers[0].mData = inputList->mBuffers[0].mData;
    ioData->mBuffers[0].mNumberChannels = 1;
    ioData->mBuffers[0].mDataByteSize = inputList->mBuffers[0].mDataByteSize;
    //*ioNumberDataPackets = 0;
    return noErr;
}

@interface AudioEngineTests : XCTestCase

@end

static GSAudioEngine* _engine = nil;

@implementation AudioEngineTests {
    
}

+(void)setUp {
    AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [sessionInstance setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];

    NSTimeInterval bufferDuration = .005;
    [sessionInstance setPreferredIOBufferDuration:bufferDuration error:&error];

    [sessionInstance setPreferredSampleRate:48000 error:&error];
    [sessionInstance setActive:YES error:&error];
    _engine = [[GSAudioEngine alloc] init];
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testAudioConverter2 {
    AudioConverterRef convert;
    AVAudioFormat* inputFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32
                                              sampleRate:48000
                                              channels:1
                                              interleaved:NO];
    AVAudioFormat* outputFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16
                                              sampleRate:48000
                                              channels:1
                                              interleaved:NO];
    
    OSStatus result = AudioConverterNew(inputFormat.streamDescription, outputFormat.streamDescription, &convert);
    NSAssert(noErr == result, @"AudioConverterNew %@", @(result));
    
    AudioBufferList inputList = {};
    inputList.mNumberBuffers = 1;
    inputList.mBuffers[0].mData = buf6;
    inputList.mBuffers[0].mDataByteSize = sizeof(buf6);
    inputList.mBuffers[0].mNumberChannels = 1;
    
    
    Byte outBuffer[512] = {0};
    AudioBufferList outputList;
    outputList.mNumberBuffers = 1;
    outputList.mBuffers[0].mData = outBuffer;
    outputList.mBuffers[0].mDataByteSize = sizeof(outBuffer);
    outputList.mBuffers[0].mNumberChannels = 1;
    AudioStreamPacketDescription aspdes = {0};
    aspdes.mDataByteSize = 512;
    aspdes.mStartOffset = 0;
    aspdes.mVariableFramesInPacket = 1;
    UInt32 outputDataPacketSize = 256;
    result = AudioConverterFillComplexBuffer(convert, inputDataProc, &inputList, &outputDataPacketSize,&outputList, &aspdes);
    NSAssert(noErr == result, @"AudioConverterFillComplexBuffer %@", @(result));
}

- (void)testAudioConverter {
    
    AudioConverterRef convert;
    AVAudioFormat* inputFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32
                                           sampleRate:48000
                                           channels:1
                                           interleaved:NO];
   AVAudioFormat* outputFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16
                                           sampleRate:48000
                                           channels:1
                                           interleaved:NO];
 
    OSStatus result = AudioConverterNew(inputFormat.streamDescription, outputFormat.streamDescription, &convert);
    NSAssert(noErr == result, @"AudioConverterNew %@", @(result));
    UInt32 outSize = 512;
    Byte outBuffer[512] = {0};
    result = AudioConverterConvertBuffer(convert,sizeof(buf6), buf6, &outSize, outBuffer);
    NSAssert(noErr == result, @"AudioConverterConvertBuffer %@", @(result));
}


- (void)testMixeNodeFormat {
    GSAudioMixerNode* mixerNode = [[GSAudioMixerNode alloc] init];
    [_engine attach:mixerNode];
    AVAudioFormat* format = [mixerNode outputFormatForBus:0];
    printASBD(*format.streamDescription);
}

- (void)testOutputNodeFormat {
    GSAudioOutputNode* output = _engine.outputNode;
    AVAudioFormat* inputFormat =  [output inputFormatForBus:0];
    AVAudioFormat* outputFormat = [output outputFormatForBus:0];
    NSLog(@"input:%@",inputFormat);
    printASBD(*inputFormat.streamDescription);
    NSLog(@"output:%@",outputFormat);
    printASBD(*outputFormat.streamDescription);
    
    AVAudioFormat* audioFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32
                                              sampleRate:48000
                                              channels:1
                                              interleaved:NO];
    printASBD(*audioFormat.streamDescription);
    
    GSAudioStreamBasicDesc asbd(48000, 1, GSAudioStreamBasicDesc::kPCMFormatFloat32, false);
    
     printASBD(asbd);
//    AVAudioFormat* outputFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16
//                                              sampleRate:48000
//                                              channels:1
//                                              interleaved:NO];
}

- (void)testInputNodeFormat {
    GSAudioInputNode* input = _engine.inputNode;
    AVAudioFormat* inputFormat =  [input inputFormatForBus:1];
    AVAudioFormat* outputFormat = [input outputFormatForBus:1];
    
    printASBD(*inputFormat.streamDescription);
    printASBD(*outputFormat.streamDescription);
}

- (void)testInpuNode {
    GSAudioInputNode* input = _engine.inputNode;
    XCTAssertEqual(input.numberOfInputs, 1);
    XCTAssertEqual(input.numberOfOutputs, 1);
    
    GSAudioOutputNode* output = _engine.outputNode;
    XCTAssertEqual(output.numberOfInputs, 1);
    XCTAssertEqual(output.numberOfOutputs, 1);
    
    GSAudioMixerNode* mixer = [[GSAudioMixerNode alloc] init];
    
    XCTAssertEqual(mixer.numberOfInputs, 0);
    XCTAssertEqual(mixer.numberOfOutputs, 0);
    
    [_engine attach:mixer];
    
    XCTAssertEqual(mixer.numberOfInputs, 8);
    XCTAssertEqual(mixer.numberOfOutputs, 1);
    
}

- (void)testAudiofile {
    NSBundle* currentBuldle = [NSBundle bundleForClass:AudioEngineTests.class];
    NSString* audioFilePath = [currentBuldle pathForResource:@"Synth" ofType:@"aif"];
    NSURL* fileURL = [NSURL fileURLWithPath:audioFilePath];
    AVAudioFile* file = [[AVAudioFile alloc] initForReading:fileURL error:nil];
    //file.fileFormat.formatDescription
}

OSStatus (inputCallback)(void *                            inRefCon,
                         AudioUnitRenderActionFlags *    ioActionFlags,
                         const AudioTimeStamp *            inTimeStamp,
                         UInt32                            inBusNumber,
                         UInt32                            inNumberFrames,
                         AudioBufferList * __nullable    ioData) {
    AudioEngineTests* test = (__bridge AudioEngineTests*) inRefCon;
    NSLog(@"%@, frames:%@", test, @(inNumberFrames));
    return noErr;
}
- (void)testVoiceProcessIOUnit {
    AudioComponentDescription ioUnitDescription;
     
    ioUnitDescription.componentType          = kAudioUnitType_Output;
    ioUnitDescription.componentSubType       = kAudioUnitSubType_VoiceProcessingIO;
    ioUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    ioUnitDescription.componentFlags         = 0;
    ioUnitDescription.componentFlagsMask     = 0;
    
    AudioComponent foundIoUnitReference = AudioComponentFindNext (
                                              NULL,
                                              &ioUnitDescription
                                          );
    AudioUnit ioUnitInstance;
    AudioComponentInstanceNew (
        foundIoUnitReference,
        &ioUnitInstance
    );
    
    UInt32 enable = 1;
       UInt32 size = sizeof(enable);
     OSStatus  result = AudioUnitSetProperty(ioUnitInstance,
                                             kAudioOutputUnitProperty_EnableIO,
                                             kAudioUnitScope_Input,
                                             1,
                                             &enable,
                                             4);
    
    NSAssert(noErr == result, @"AudioUnitSetProperty kAudioOutputUnitProperty_EnableIO %@", @(result));
    
    AURenderCallbackStruct callback = {0};
    callback.inputProc = inputCallback;
    callback.inputProcRefCon = (__bridge void*)self;
    result = AudioUnitSetProperty(ioUnitInstance, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 1, &callback, sizeof(callback));
    NSAssert(noErr == result, @"AudioUnitInitialize kAudioOutputUnitProperty_SetInputCallback%@", @(result));
    
    result = AudioUnitInitialize(ioUnitInstance);
    NSAssert(noErr == result, @"AudioUnitInitialize %@", @(result));
    
    result = AudioOutputUnitStart(ioUnitInstance);
    NSAssert(noErr == result, @"AudioUnitInitialize %@", @(result));
    sleep(10);
    
    
//    AudioComponent componenet = AudioComponentFindNext(nullptr, &voice_desc);
//           OSStatus result = AudioComponentInstanceNew(componenet, &self.audioUnit.audioUnitRef);
//            NSAssert(noErr == result, @"AudioComponentInstanceNew %@", @(result));
    
}

- (void)testAddTwoIONodeToGraph {
    // 无法添加两个 IO Unit 到 AUGraph 中
    AUGraph graph;
    OSStatus result = NewAUGraph(&graph);
    NSAssert(noErr == result,@"NewAUGraph %@",@(result));
    
    AudioComponentDescription inputcd = {0};
    inputcd.componentType = kAudioUnitType_Output;
    inputcd.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
    inputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    AUNode inputNode;
    result = AUGraphAddNode(graph, &inputcd, &inputNode);
    NSAssert(noErr == result,@"AUGraphAddNode %@",@(result));
    
    AudioComponentDescription outputcd = {0};
    outputcd.componentType = kAudioUnitType_Output;
    outputcd.componentSubType = kAudioUnitSubType_RemoteIO;
    outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    AUNode outputNode;
    result = AUGraphAddNode(graph, &outputcd, &outputNode);
    NSAssert(noErr == result,@"AUGraphAddNode %@",@(result));
}

- (void)testAudioFileID {
    AudioFileID inputFile1;
    AudioFileID inputFile2;
    NSBundle* currentBuldle = [NSBundle bundleForClass:AudioEngineTests.class];
    NSString* audioFilePath = [currentBuldle pathForResource:@"Synth" ofType:@"aif"];
    NSURL* fileURL = [NSURL fileURLWithPath:audioFilePath];
    OSStatus result =  AudioFileOpenURL((__bridge CFURLRef)fileURL,
                                        kAudioFileReadPermission,
                                        kAudioFileAIFFType,
                                        &inputFile1);
    NSAssert(noErr == result, @"AudioFileOpenURL %@", @(result));
    result =  AudioFileOpenURL((__bridge CFURLRef)fileURL,
                                kAudioFileReadPermission,
                                kAudioFileAIFFType,
                                &inputFile2);
    NSAssert(noErr == result, @"AudioFileOpenURL %@", @(result));
    XCTAssertNotEqual(inputFile1, inputFile2);
}

- (void)testMultiChandelAudioMixer {
    /// 1 创建 graph 对象
    /// 2 向 graph 对象中添加节点
    /// 3  对 graph 对象做 open 操作
    /// 4 获取 节点对应的 audio unit 的引用
    /// 5 连接节点，构造节点间的边
    /// 6 初始化 graph 对象
    /// 7 启动 graph 对象
    AudioStreamBasicDescription inputFormat;
    AudioFileID inputFile;
    AUGraph graph;
    AudioUnit fileAU;
    AudioUnit mixerAU;
    AudioUnit outputAU;

    OSStatus result = NewAUGraph(&graph);
    NSAssert(noErr == result,@"NewAUGraph %@",@(result));
    NSLog(@"NewAUGraph");

    result = AUGraphOpen(graph);
    NSLog(@"open graph");
    NSAssert(noErr == result,@"AUGraphOpen %@",@(result));
    
    AudioComponentDescription outputcd = {0};
    outputcd.componentType = kAudioUnitType_Output;
    outputcd.componentSubType = kAudioUnitSubType_RemoteIO;
    outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    AUNode outputNode;
    result = AUGraphAddNode(graph, &outputcd, &outputNode);
    NSAssert(noErr == result,@"AUGraphAddNode %@",@(result));
    NSLog(@"kAudioUnitSubType_RemoteIO addNode:%@",@(outputNode));

    AudioComponentDescription fileplayercd = {0};
    fileplayercd.componentType = kAudioUnitType_Generator;
    fileplayercd.componentSubType = kAudioUnitSubType_AudioFilePlayer;
    fileplayercd.componentManufacturer = kAudioUnitManufacturer_Apple;
    AUNode fileNode;
    result = AUGraphAddNode(graph, &fileplayercd, &fileNode);
    NSAssert(noErr == result,@"AUGraphAddNode %@",@(result));
    NSLog(@"kAudioUnitSubType_AudioFilePlayer addNode:%@",@(fileNode));
    
    AudioComponentDescription mixercd = {0};
    mixercd.componentType = kAudioUnitType_Mixer;
    mixercd.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    mixercd.componentManufacturer = kAudioUnitManufacturer_Apple;
    AUNode mixerNode;
    result = AUGraphAddNode(graph, &mixercd, &mixerNode);
    NSAssert(noErr == result,@"AUGraphAddNode %@",@(result));
    NSLog(@"kAudioUnitSubType_MultiChannelMixer addNode:%@",@(mixerNode));



    result = AUGraphNodeInfo(graph,fileNode, NULL, &fileAU);
    NSAssert(noErr == result,@"AUGraphNodeInfo %@",@(result));
    NSLog(@"initialize %p",fileAU);
    
    result = AUGraphNodeInfo(graph,mixerNode, NULL, &mixerAU);
    NSAssert(noErr == result,@"AUGraphNodeInfo %@",@(result));
    NSLog(@"initialize %p",mixerAU);
    
    result = AUGraphNodeInfo(graph,outputNode, NULL, &outputAU);
    NSAssert(noErr == result,@"AUGraphNodeInfo %@",@(result));
    NSLog(@"initialize %p",outputAU);
    
    
    result = AUGraphConnectNodeInput(graph, fileNode, 0, mixerNode, 0);
    NSAssert(noErr == result,@"AUGraphConnectNodeInput %@",@(result));
    NSLog(@"connect:%@ to:%@",@(fileNode), @(mixerNode));

    result = AUGraphConnectNodeInput(graph, mixerNode, 0, outputNode, 0);
    NSAssert(noErr == result,@"AUGraphConnectNodeInput %@",@(result));
    NSLog(@"connect:%@ to:%@",@(mixerNode), @(outputNode));
    

    result = AUGraphInitialize(graph);
    NSAssert(noErr == result,@"AUGraphInitialize %@",@(result));
    NSLog(@"AUGraphInitialize");

    NSBundle* currentBuldle = [NSBundle bundleForClass:AudioEngineTests.class];
    NSString* audioFilePath = [currentBuldle pathForResource:@"Synth" ofType:@"aif"];
    NSURL* fileURL = [NSURL fileURLWithPath:audioFilePath];
    result =  AudioFileOpenURL((__bridge CFURLRef)fileURL,
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

    // Calculating File Playback Time in Seconds
    NSInteger duration =  nPackets * inputFormat.mFramesPerPacket / inputFormat.mSampleRate;

    result = AUGraphStart(graph);
    NSAssert(noErr == result,@"AUGraphStart %@",@(result));
    NSLog(@"AUGraphStart");
    NSLog(@"start playing duration %@ s", @(duration));
    usleep ((int)(duration * 1000.0 * 1000.0) * rgn.mLoopCount);
    NSLog(@"stop play");
    AUGraphStop(graph);
    AUGraphUninitialize(graph);
    AUGraphClose(graph);
    AudioFileClose(inputFile);
}

- (void)testAudioUnitFilePlayer {
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
