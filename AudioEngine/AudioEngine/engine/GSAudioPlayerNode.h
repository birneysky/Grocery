//
//  GSAudioPlayerNode.h
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "GSAudioIONode.h"
#import "GSAudioMixing.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSAudioPlayerNode : GSAudioIONode <GSAudioMixing>

- (instancetype)initWithFileURL:(NSURL*)fileURL;

///  开始或者继续播放
- (void)play;
/// 停止播放， 调用该方法后，调用play 方法会从文件起始位置开始播放
- (void)stop;
/// 暂停播放，继续时可调用 play 方法
- (void)pause;

@property (nonatomic, readonly) BOOL isPlaying;

@end

NS_ASSUME_NONNULL_END
