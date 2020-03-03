//
//  GSAudioNode.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "GSAudioNode.h"
#import "GSAudioUnit.h"

@interface GSAudioNode () <GSAudioUnitDelegate>

@property (nonatomic,strong) GSAudioUnit* audioUnit;
@property (nonatomic, assign) AUNode node;

@end

@implementation GSAudioNode {
    GSAudioUnit* _audioUnit;
    AUNode _node;
}

- (instancetype)initWithCommponenetDESC:(AudioComponentDescription)desc {
    if (self = [super init]) {
        _audioUnit = [[GSAudioUnit alloc] initWithComponentDescription:desc];
    }
    return self;
}

- (void)setAUNode:(AUNode)node {
    _node = node;
}

- (GSAudioUnit*)audioUnit  {
    return _audioUnit;
}

- (AUNode)node {
    return _node;
}

@end
