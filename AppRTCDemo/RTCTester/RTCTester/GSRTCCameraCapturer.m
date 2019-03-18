//
//  RongCameraCapturer.m
//  RongRTCLib
//
//  Created by zhaobingdong on 2019/1/9.
//  Copyright © 2019年 Bailing Cloud. All rights reserved.
//

#import "GSRTCCameraCapturer.h"
//#import "RongRTCVideoCaptureParam.h"

@interface GSRTCCameraCapturer() <AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic, strong) AVCaptureSession *captureSession;
@property(nonatomic, weak) AVCaptureDeviceInput *activeVideoInput;
@property(nonatomic, strong) dispatch_queue_t sessionQueue;
@property(nonatomic, strong) AVCaptureConnection *videoConnection;
@property(nonatomic, assign) AVCaptureVideoOrientation videoBufferOrientation;
@property(nonatomic, weak) AVCaptureVideoDataOutput* videoDataOutput;
@end

@implementation GSRTCCameraCapturer

- (instancetype)init {
    if (self = [super init]) {
        [self setupCaptureSession];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<RTCVideoCapturerDelegate>)delegate {
    if (self = [super initWithDelegate:delegate]) {
        [self setupCaptureSession];
    }
    return self;
}

- (void)startRunning {
    if (![self.captureSession isRunning]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(self.sessionQueue, ^{
            [weakSelf.captureSession startRunning];
        });
    }
}

- (void)stopRunning {
    if ([self.captureSession isRunning]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(self.sessionQueue, ^{
            [weakSelf.captureSession stopRunning];
            //[weakSelf teardownCaptureSession];
        });
    }
}

- (BOOL)switchCamera {
    if (![self canSwitchCameras]) {
        return NO;
    }
    
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (videoInput) {
        [self.captureSession beginConfiguration];
        [self.captureSession removeInput:self.activeVideoInput];
        if ([self.captureSession canAddInput:videoInput]) {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        } else {
            [self.captureSession addInput:self.activeVideoInput];
        }

        [self.captureSession removeOutput:self.videoDataOutput];
        
        AVCaptureVideoDataOutput* videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        videoDataOutput.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
        [videoDataOutput setSampleBufferDelegate:self queue:self.sessionQueue];
        if ([self.captureSession canAddOutput:videoDataOutput]) {
            [self.captureSession addOutput:videoDataOutput];
            self.videoDataOutput = videoDataOutput;
        }
        self.videoConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
        self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
        if (videoDevice.position == AVCaptureDevicePositionBack) {
            self.videoConnection.videoMirrored = NO;
        } else {
            self.videoConnection.videoMirrored = YES;
        }
        [self.captureSession commitConfiguration];
        
    } else {
        ////error
        return NO;
    }
    return YES;
}

#pragma mark - Helper
- (void)setupCaptureSession {
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(sessionWasInterrupted:)
                          name:AVCaptureSessionWasInterruptedNotification
                        object:nil];
    

    
    /*video*/
    AVCaptureDevice* device = [self cameraWithPosition:AVCaptureDevicePositionFront];
    if (!device) {
        device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    }
    AVCaptureDeviceInput *videoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    if ([self.captureSession canAddInput:videoDeviceInput]) {
        [self.captureSession addInput:videoDeviceInput];
        self.activeVideoInput = videoDeviceInput;
    }
    
    AVCaptureVideoDataOutput* videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    videoDataOutput.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
    videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    
    [videoDataOutput setSampleBufferDelegate:self queue:self.sessionQueue];
    videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    if ([self.captureSession canAddOutput:videoDataOutput]) {
        [self.captureSession addOutput:videoDataOutput];
        self.videoDataOutput = videoDataOutput;
    }
    
    self.videoConnection = [videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    if (self.videoConnection.isVideoOrientationSupported) {
        self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    if(self.videoConnection.isVideoMirroringSupported) {
        self.videoConnection.videoMirrored = YES;
    }
    
    self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    
    CMTime frameDuration = CMTimeMake(1, 25);
    
    NSError *error = nil;
    if ([device lockForConfiguration:&error]) {
        device.activeVideoMaxFrameDuration = frameDuration;
        device.activeVideoMinFrameDuration = frameDuration;
        [device unlockForConfiguration];
    }
    
    self.videoBufferOrientation = self.videoConnection.videoOrientation;
    
}

- (void)teardownCaptureSession {
    if (self.captureSession) {
        self.captureSession = nil;
    }
}

- (BOOL)canSwitchCameras {
    return self.cameraCount > 1;
}

- (NSUInteger)cameraCount {
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (AVCaptureDevice *)activeCamera {
    return self.activeVideoInput.device;
}

- (AVCaptureDevice *)inactiveCamera {
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if (AVCaptureDevicePositionBack == [self activeCamera].position) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

#pragma mark - Notification Selector
- (void)sessionWasInterrupted:(NSNotification *)notification {
    NSLog(@"Capture session was interrupted with reason: %@", notification);
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output
        didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    [self.delegate1 didOutputSampleBuffer:sampleBuffer];
    
    if (CMSampleBufferGetNumSamples(sampleBuffer) != 1 || !CMSampleBufferIsValid(sampleBuffer) ||
        !CMSampleBufferDataIsReady(sampleBuffer)) {
        return;
    }
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer == nil) {
        return;
    }
    
    RTCCVPixelBuffer *rtcPixelBuffer = [[RTCCVPixelBuffer alloc] initWithPixelBuffer:pixelBuffer];
    int64_t timeStampNs =
    CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)) * NSEC_PER_SEC;
    RTCVideoFrame *videoFrame = [[RTCVideoFrame alloc] initWithBuffer:rtcPixelBuffer
                                                             rotation:RTCVideoRotation_0
                                                          timeStampNs:timeStampNs];
    [self.delegate capturer:self didCaptureVideoFrame:videoFrame];
    
}

#pragma mark - Getters

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

- (dispatch_queue_t)sessionQueue {
    if (!_sessionQueue) {
        _sessionQueue = dispatch_queue_create("cn.rong.camera.capturer.session", DISPATCH_QUEUE_SERIAL);
    }
    return _sessionQueue;
}

@end
