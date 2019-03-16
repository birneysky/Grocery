//
//  RongRTCRemoteVideoView+Private.h
//  RongRTCLib
//
//  Created by LiuLinhong on 2019/01/16.
//  Copyright © 2019 Bailing Cloud. All rights reserved.
//

#import "GSRTCRemoteVideoView.h"
#import <WebRTC/RTCEAGLVideoView.h>

NS_ASSUME_NONNULL_BEGIN


@interface GSRTCRemoteVideoView (Private)

@property (nonatomic,strong) RTCEAGLVideoView* eaglView;

@end

NS_ASSUME_NONNULL_END
