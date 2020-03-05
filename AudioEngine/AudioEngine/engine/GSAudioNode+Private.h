//
//  GSAudioNode+Private.h
//  AudioEngine
//
//  Created by birney on 2020/3/2.
//  Copyright © 2020 rongcloud. All rights reserved.
//


#import "GSAudioNode.h"
#import "GSAudioNodeDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface GSAudioNode ()

- (instancetype)initWithCommponenetDESC:(AudioComponentDescription)desc NS_DESIGNATED_INITIALIZER;
/// 设置节点在引擎图中节点索引
- (void)setAUNode:(AUNode)node;
/// 完成初始化时调用
- (void)didFinishInitializing;

/// 记录该节点的已建立连接输入 bus
/// @param bus bus 标识
- (void)addConnectedInputBus:(GSAudioNodeBus)bus;

/// 记录该节点的已建立连接输出 bus
/// @param bus bus 标识
- (void)addConnectedOutputBus:(GSAudioNodeBus)bus;

@property (nonatomic, weak) id<GSAudioNodeDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
