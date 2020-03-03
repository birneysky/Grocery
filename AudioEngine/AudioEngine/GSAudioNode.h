//
//  GSAudioNode.h
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN
@class GSAudioUnit;

@interface GSAudioNode : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) GSAudioUnit* audioUnit;
@property (nonatomic, readonly) AUNode node;

@end

NS_ASSUME_NONNULL_END
