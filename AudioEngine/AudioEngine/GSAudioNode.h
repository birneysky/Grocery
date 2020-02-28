//
//  GSAudioNode.h
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class GSAudioUnit;

@interface GSAudioNode : NSObject

@property (nonatomic, readonly) GSAudioUnit* audioUnit;

@end

NS_ASSUME_NONNULL_END
