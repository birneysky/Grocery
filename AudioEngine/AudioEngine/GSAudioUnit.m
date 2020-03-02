//
//  GSAudioUnit.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "GSAudioUnit.h"

@interface GSAudioUnit()

@end

@implementation GSAudioUnit {
    AudioComponent _component;
    AudioUnit _unitInstance;
    AudioComponentDescription _acdesc;
}

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription {
    if (self = [super init]) {
        //_component = AudioComponentFindNext (NULL,&componentDescription);
        //AudioComponentInstanceNew (_component,&_unitInstance);
        _acdesc = componentDescription;
    }
    return self;
}

- (void)setAudioUnit:(AudioUnit)unit {
    _unitInstance = unit;
}

- (AudioUnit)instance {
    return _unitInstance;
}

- (AudioComponent)component {
    return _component;
}

@end
