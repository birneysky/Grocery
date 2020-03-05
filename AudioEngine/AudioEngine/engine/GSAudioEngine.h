//
//  GSAudioEngine.h
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class GSAudioNode;
@class GSAudioInputNode;

@interface GSAudioEngine : NSObject

@property (nonatomic, readonly) GSAudioInputNode* inputNode;
@property (nonatomic, readonly) BOOL isRunning;
- (void)attach:(GSAudioNode*)node;
- (void)detach:(GSAudioNode*)node;
- (void)prepare;
- (void)start;
- (void)stop;

/// 连接源节点的输出到目的节点的输入
/// @param src  源节点
/// @param dst 目标节点
- (void)connect:(GSAudioNode*)src to:(GSAudioNode*)dst;
@end

NS_ASSUME_NONNULL_END
