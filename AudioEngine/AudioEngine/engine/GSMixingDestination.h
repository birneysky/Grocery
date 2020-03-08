//
//  GSMixingDest.h
//  AudioEngine
//
//  Created by birney on 2020/3/5.
//  Copyright © 2020 Pea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSAudioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GSMixingVolumeControllable;
@interface GSMixingDestination : NSObject
@property (nonatomic, weak, nullable) id<GSMixingVolumeControllable> node;
@property (nonatomic, assign) GSAudioNodeBus bus;

@end

NS_ASSUME_NONNULL_END
