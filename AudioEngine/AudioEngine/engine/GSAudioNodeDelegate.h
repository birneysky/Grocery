//
//  GSAudioNodeDelegate.h
//  AudioEngine
//
//  Created by birney on 2020/3/5.
//  Copyright © 2020 Pea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSAudioEngineStructures.h"

NS_ASSUME_NONNULL_BEGIN

@class GSAudioNode;
@class GSMixingDestination;

@protocol GSAudioNodeDelegate <NSObject>

- (GSMixingDestination*)mixingDestinationOfNode:(GSAudioNode*)src;

@end

NS_ASSUME_NONNULL_END
