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

@interface GSAudioEngine : NSObject

@property (nonatomic, readonly) BOOL isRunning;
- (void)prepare;
- (void)start;
- (void)stop;
- (void)attach:(GSAudioNode*)node;
- (void)detach:(GSAudioNode*)node;
- (void)connect:(GSAudioNode*)nodeA to:(GSAudioNode*)nodeB;
@end

NS_ASSUME_NONNULL_END
