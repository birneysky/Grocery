//
//  GSAudioUnit.h
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN


@interface GSAudioUnit : NSObject

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription;

@property(nonatomic, readonly) AudioComponent component;
@property(nonatomic, readonly) AudioUnit instance;
@property(nonatomic, readonly) NSString *componentName;

@property(nonatomic, getter=isInputEnabled) BOOL inputEnabled;
@property(nonatomic, getter=isOutputEnabled) BOOL outputEnabled;

@end

NS_ASSUME_NONNULL_END
