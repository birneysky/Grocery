//
//  GSAudioUnit.h
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GSAudioUnitDelegate <NSObject>
@optional
- (void)didcreatedAudioUnitInstance;
@end


@interface GSAudioUnit : NSObject

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription;

@property(nonatomic, readonly) AudioComponentDescription acdesc;
@property(nonatomic, readonly) AudioUnit instance;
@property(nonatomic, weak) id<GSAudioUnitDelegate> delegate;
@property(nonatomic, getter=isInputEnabled) BOOL inputEnabled;
@property(nonatomic, getter=isOutputEnabled) BOOL outputEnabled;

@end

NS_ASSUME_NONNULL_END
