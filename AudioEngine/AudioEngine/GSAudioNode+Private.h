//
//  GSAudioNode+Private.h
//  AudioEngine
//
//  Created by birney on 2020/3/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//


#import "GSAudioNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSAudioNode ()

- (instancetype)initWithCommponenetDESC:(AudioComponentDescription)desc NS_DESIGNATED_INITIALIZER;
- (void)setAUNode:(AUNode)node;
- (void)didFinishInitializing;
- (void)didConnectedNodeInputBus:(GSAudioNodeBus)bus;
- (void)didConnectedNodeOutputBus:(GSAudioNodeBus)bus;
@end

NS_ASSUME_NONNULL_END
