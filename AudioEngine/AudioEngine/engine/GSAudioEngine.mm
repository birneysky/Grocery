//
//  GSAudioEngine.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "GSAudioEngine.h"
#import "GSAudioNode.h"
#import "GSAudioUnit.h"
#import "GSAudioNode+Private.h"
#import "GSAudioUnit+Private.h"
#import "GSAudioNodeDelegate.h"
#import "GSMixingDestination.h"
#import "GSAudioInputNode.h"
#import "GSAudioInputNode+Private.h"

@interface GSAudioEngine() <GSAudioNodeDelegate>

@property (nonatomic,assign) BOOL isRunning;
@property (nonatomic, strong) NSMutableArray<GSAudioNode*>* nodes;
@property (nonatomic, strong) NSMutableDictionary<id,GSMixingDestination*>* pathes;
@property (nonatomic, strong) GSAudioInputNode* inputNode;
@end

@implementation GSAudioEngine {
    AUGraph   _graph;
    AudioUnit mainMixer;
    AudioUnit output;
}

#pragma mark - Init
- (instancetype) init {
    if (self = [super init]) {
        OSStatus result = NewAUGraph(&_graph);
        NSAssert(noErr == result,@"NewAUGraph %@",@(result));
        result = AUGraphOpen(_graph);
        NSAssert(noErr == result,@"AUGraphOpen %@",@(result));
    }
    return self;
}

- (void)dealloc {
    DisposeAUGraph(_graph);
}

#pragma mark - Apis
- (void)prepare {
    OSStatus result = AUGraphInitialize(_graph);
    NSAssert(noErr == result, @"AUGraphInitialize %@", @(result));
    [self.nodes makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
    [self.nodes makeObjectsPerformSelector:@selector(didFinishInitializing)];
}
- (void)start {
    if (self.isRunning) {
        return;
    }
    OSStatus result = AUGraphStart(_graph);
    NSAssert(noErr == result, @"AUGraphStart %@", @(result));
    /// 注意这里不要使用 self.inputNode,  当外部没有明确访问 inputNode时， 不创建该实例
    [_inputNode start];
}

- (void)stop {
    if (self.isRunning) {
        OSStatus result = AUGraphStop(_graph);
        NSAssert(noErr == result, @"AUGraphStop %@", @(result));
    }
}

- (BOOL)isRunning {
    return NO;
}

- (void)attach:(GSAudioNode*)node {
    AUNode outNode;
    AudioComponentDescription desc = node.audioUnit.acdesc;
    OSStatus result = AUGraphAddNode(_graph, &desc, &outNode);
    NSAssert(noErr == result, @"AUGraphAddNode result %@",@(result));
    
    AudioUnit outUnit;
    result = AUGraphNodeInfo(_graph, outNode, NULL, &outUnit);
    NSAssert(noErr == result, @"AUGraphNodeInfo result %@",@(result));
    
    [node setAUNode:outNode];
    [node.audioUnit setAudioUnit:outUnit];
    [self.nodes addObject:node];
}

- (void)detach:(GSAudioNode*)node {
    
}

- (void)connect:(GSAudioNode*)src to:(GSAudioNode*)dst {
    GSAudioNodeBus dstInputBus = dst.availableInputBus;
    GSAudioNodeBus srcOutputBus = src.availableOutputBus;
    NSAssert(InvalidAudioBus != srcOutputBus, @" %@ no ouput bus available",src);
    NSAssert(InvalidAudioBus != dstInputBus, @" %@ no input bus available",dst);
    
    OSStatus result = AUGraphConnectNodeInput(_graph,
                                              src.node,
                                              (AUNode)srcOutputBus,
                                              dst.node,
                                              (AUNode)dstInputBus);
    
    [src addConnectedOutputBus:srcOutputBus];
    [dst addConnectedInputBus:dstInputBus];
    GSMixingDestination* destination =  self.pathes[src];
    if (!destination && [dst conformsToProtocol:@protocol(GSMixingVolumeControllable)]) {
        destination = [[GSMixingDestination alloc] init];
        destination.node = (id<GSMixingVolumeControllable>)dst;
        destination.bus = dstInputBus;
        [self.pathes setObject:destination forKey:src];
    }
    
    NSAssert(noErr == result, @"AUGraphConnectNodeInput %@", @(result));
}
#pragma mark - GSAudioNodeDelegate
- (GSMixingDestination*)mixingDestinationOfNode:(GSAudioNode*)src {
    return self.pathes[src];
}

#pragma mark - Getters
- (NSMutableArray<GSAudioNode*>*)nodes {
    if (!_nodes) {
        _nodes = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return _nodes;
}

- (NSMutableDictionary*)pathes {
    if (!_pathes) {
        _pathes = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return _pathes;
}

- (GSAudioInputNode*)inputNode {
    if (!_inputNode) {
        GSComponentDesc output_desc(kAudioUnitType_Output,
                                    kAudioUnitSubType_VoiceProcessingIO,
                                    kAudioUnitManufacturer_Apple);
        _inputNode = [[GSAudioInputNode alloc] initWithCommponenetDESC:output_desc];
    }
    return _inputNode;
}

@end
