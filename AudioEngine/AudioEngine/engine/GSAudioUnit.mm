//
//  GSAudioUnit.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 Pea. All rights reserved.
//

#import "GSAudioUnit.h"

@interface GSAudioUnit()

@end

@implementation GSAudioUnit {
    AudioComponent _component;
    AudioUnit _unitInstance;
    AUNode _auNode;
    AudioComponentDescription _acdesc;
}

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription {
    if (self = [super init]) {
        _acdesc = componentDescription;
    }
    return self;
}

- (void)setAudioUnit:(AudioUnit)unit {
    _unitInstance = unit;
    if ([self.delegate respondsToSelector:@selector(didCreatedAudioUnitInstance)]) {
        [self.delegate didCreatedAudioUnitInstance];
    }
}

- (void)setAuNode:(AUNode)node {
    _auNode = node;
}

- (AUNode)auNode {
    return _auNode;
}

- (AudioUnit&)audioUnitRef {
    return _unitInstance;
}

- (AudioUnit)instance {
    return _unitInstance;
}

- (AudioComponent)component {
    return _component;
}



@end
