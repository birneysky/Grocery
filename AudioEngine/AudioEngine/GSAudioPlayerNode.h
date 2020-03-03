//
//  GSAudioPlayerNode.h
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "GSAudioIONode.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSAudioPlayerNode : GSAudioIONode

- (instancetype)initWithFileURL:(NSURL*)fileURL;

- (void)play;

- (void)stop;

- (void)pause;

-(void)schedule;

@property (nonatomic, readonly) BOOL isPlaying;

@end

NS_ASSUME_NONNULL_END
