//
//  RongCameraCapturer.h
//  RongRTCLib
//
//  Created by zhaobingdong on 2019/1/9.
//  Copyright © 2019年 Bailing Cloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <WebRTC/WebRTC.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GSCameraCapturerDelegate <NSObject>

/**
 音视频样本输出是会调用该方法
 
 @param sampleBuffer 音频或者视频样本
 */
- (void)didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

@class GSRTCVideoCaptureParam;

@interface GSRTCCameraCapturer : RTCVideoCapturer

- (instancetype)initWithDelegate:(id<RTCVideoCapturerDelegate>)delegate;

@property(nonatomic,weak) id<GSCameraCapturerDelegate> delegate1;

/**
 采集参数
 */
//@property (nonatomic,strong) RongRTCVideoCaptureParam* captureParams;

/**
 开始采集
 */
- (void)startRunning;

/**
 结束采集
 */
- (void)stopRunning;

/**
 切换摄像头
 
 @return 成功返回YES，失败返回NO
 */
- (BOOL)switchCamera;


@end

NS_ASSUME_NONNULL_END
