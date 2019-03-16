//
//  RCLocalPreviewView.h
//  RongRTCLib
//
//  Created by zhaobingdong on 2018/12/17.
//  Copyright © 2018年 Bailing Cloud. All rights reserved.
//

#import "GSRTCVideoPreviewView.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSRTCLocalVideoView : GSRTCVideoPreviewView


-(void)renderSampleBuffer:(CMSampleBufferRef)sample;

@end

NS_ASSUME_NONNULL_END
