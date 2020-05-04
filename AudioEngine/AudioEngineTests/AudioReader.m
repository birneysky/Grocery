//
//  AudioReader.m
//  AudioEngineTests
//
//  Created by birney on 2020/5/3.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "AudioReader.h"

@interface AudioReader ()
@property (nonatomic, strong) AVAssetReader* reader;
@property (nonatomic, strong) AVAssetReaderTrackOutput* output;
@property (nonatomic, strong) AVAudioFormat* format;
@end

@implementation AudioReader

- (instancetype)initWithFileURL:(NSURL*)url {
    if (self = [super init]) {
        AVAsset* asset = [AVAsset assetWithURL:url];
        AVAssetTrack * audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
        NSDictionary* settings = @{AVFormatIDKey:               @(kAudioFormatLinearPCM),
                                   AVSampleRateKey:             @(48000),
                                   AVNumberOfChannelsKey:       @(1),
                                   AVLinearPCMIsNonInterleaved: @(NO)};
       _output = [[AVAssetReaderTrackOutput alloc] initWithTrack:audioTrack outputSettings:settings];
       _reader = [AVAssetReader assetReaderWithAsset:asset error:nil];
        if ([_reader canAddOutput:_output]) {
            [_reader addOutput:_output];
        }
        [_reader startReading];
    }
    return self;
}

- (void)dealloc {
    [_reader cancelReading];
}

- (AVAudioFormat*)format {
    if (!_format) {
        _format = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatInt16 sampleRate:48000 channels:1 interleaved:NO];
    }
    return _format;
}

- (AVAudioFormat*)outputFormat {
    
    return self.format;
}

- (CMSampleBufferRef)fetchNextSampleBuffer {
    return [_output copyNextSampleBuffer];
}

- (AVAssetReaderStatus)status {
    return self.reader.status;
}


@end
