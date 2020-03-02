//
//  GSAudioPlayerNode.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "GSAudioPlayerNode.h"
#import "GSComponentDescription.h"
#import "GSAudioUnit.h"

@interface GSAudioPlayerNode()

@property (nonatomic, strong) GSAudioUnit* audioUnit;
@property (nonatomic, assign) AUNode node;
@end


@implementation GSAudioPlayerNode {
    AudioFileID _audioFileID;
    ScheduledAudioFileRegion _region;
    AudioStreamBasicDescription _unitASBD;
    AudioStreamBasicDescription _fileASBD;
}

@synthesize audioUnit = _audioUnit;
@synthesize node = _node;

- (instancetype)init {
    if (self = [super init]) {
        GSComponentDescription player_desc(kAudioUnitType_Generator,
                                          kAudioUnitSubType_ScheduledSoundPlayer,
                                          kAudioUnitManufacturer_Apple);
        _audioUnit = [[GSAudioUnit alloc] initWithComponentDescription:player_desc];
    }
    return self;
}

@end
