//
//  GSMultiChannelVolumeControl.h
//  AudioEngine
//
//  Created by birney on 2020/3/5.
//  Copyright © 2020 Pea. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GSMixingVolumeControllable <NSObject>

- (void)setInputVolume:(GSAudioVolume) volume inputBus:(GSAudioNodeBus)bus;

@end

NS_ASSUME_NONNULL_END
