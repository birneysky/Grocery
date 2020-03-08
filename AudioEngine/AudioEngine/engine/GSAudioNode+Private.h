//
//  GSAudioNode+Private.h
//  AudioEngine
//
//  Created by birney on 2020/3/2.
//  Copyright © 2020 Pea. All rights reserved.
//


#import "GSAudioNode.h"
#import "GSAudioNodeDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface GSAudioNode ()

- (instancetype)initWithCommponenetDESC:(AudioComponentDescription)desc NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithAudioUnit:(GSAudioUnit*)node;

/// 完成初始化时调用
- (void)didFinishInitializing;

/// 记录该节点的已建立连接输入 bus
/// @param bus bus 标识
- (void)addConnectedInputBus:(GSAudioNodeBus)bus;

/// 记录该节点的已建立连接输出 bus
/// @param bus bus 标识
- (void)addConnectedOutputBus:(GSAudioNodeBus)bus;

@property (nonatomic, weak) id<GSAudioNodeDelegate> delegate;
@property (nonatomic, assign) GSAudioNodeBus availableOutputBus;
@property (nonatomic, assign) GSAudioNodeBus availableInputBus;
@end

NS_ASSUME_NONNULL_END
