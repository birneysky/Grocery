//
//  GSAudioMixerNode.h
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "GSAudioNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSAudioMixerNode : GSAudioNode

- (instancetype)init;

@property (nonatomic, assign) float outputVolume;
@end

NS_ASSUME_NONNULL_END
