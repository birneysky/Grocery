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

@interface GSAudioOutputNode()

@end

@implementation GSAudioOutputNode

- (instancetype)init {
    GSComponentDesc output_desc(kAudioUnitType_Output,
                                kAudioUnitSubType_RemoteIO,
                                kAudioUnitManufacturer_Apple);
    if (self = [super initWithCommponenetDESC:output_desc]) {
    }
    return self;
}

@end
