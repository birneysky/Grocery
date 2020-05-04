//
//  AudioReader.h
//  AudioEngineTests
//
//  Created by birney on 2020/5/3.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioReader : NSObject

- (instancetype)initWithFileURL:(NSURL*)url;

- (AVAudioFormat*)outputFormat;

- (AVAssetReaderStatus)status;

- (CMSampleBufferRef)fetchNextSampleBuffer;

@end

NS_ASSUME_NONNULL_END
