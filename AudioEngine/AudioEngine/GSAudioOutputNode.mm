//
//  GSAudioOutputNode.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "GSAudioOutputNode.h"
#import "GSComponentDescription.h"
#import "GSAudioUnit.h"

@interface GSAudioUnit()

@property (nonatomic,strong) GSAudioUnit* audioUnit;
@property (nonatomic, assign) AUNode node;
@end


@implementation GSAudioOutputNode
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
