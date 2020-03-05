//
//  GSAudioMixing.h
//  AudioEngine
//
//  Created by birney on 2020/3/4.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 适用于连接于混音节点的 input  bus 的协议
@protocol GSAudioMixing <NSObject>

///  混音音量控制
@property (nonatomic) float inputVolume;


@end

NS_ASSUME_NONNULL_END
