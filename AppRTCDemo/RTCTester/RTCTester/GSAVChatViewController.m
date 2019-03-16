//
//  ViewController.m
//  RTCTester
//
//  Created by birney on 2019/1/9.
//  Copyright © 2019年 RongCloud. All rights reserved.
//

#import "GSAVChatViewController.h"
#import "GSRTCLocalVideoView.h"
#import "GSRTCCameraCapturer.h"
#import <WebRTC/WebRTC.h>
#import "GSRTCRemoteVideoView.h"
#import "RongRTCRemoteVideoView+Private.h"

@interface GSAVChatViewController () <GSCameraCapturerDelegate,RTCPeerConnectionDelegate>
@property (weak, nonatomic) IBOutlet RTCMTLVideoView *removeVideoView;
@property (weak, nonatomic) IBOutlet GSRTCLocalVideoView *localView;
@property (nonatomic,strong) GSRTCCameraCapturer* cameraCapturer;
@property (nonatomic,strong) RTCPeerConnectionFactory* factory;
@property (nonatomic,strong) RTCPeerConnection* peerConnection;
@property (nonatomic,strong) RTCAudioSource* audioSource;
@property (nonatomic,strong) RTCAudioTrack* audioTrack;
@property (nonatomic,strong) RTCVideoSource* videoSource;
@property (nonatomic,strong) RTCVideoTrack* videoTrack;
@property(nonatomic,strong) RTCMediaStream* mediaStream;
@property (nonatomic,strong) RTCVideoTrack* videoTrack1;
@end

static NSString * const kARDMediaStreamId = @"ARDAMS";
static NSString * const kARDAudioTrackId = @"ARDAMSa0";
static NSString * const kARDVideoTrackId = @"ARDAMSv0";
static NSString * const kARDVideoTrackKind = @"video";

@implementation GSAVChatViewController
- (void)dealloc {
     NSLog(@"♻️♻️♻️♻️♻️ %@ dealloc %@",self.class,self);
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
//    self.localView.filleMode = RCVideoFillModeAspect;
//    [[RongRTCEngine sharedEngine] startCapture:nil];
//    [[RongRTCEngine sharedEngine] setLocalVideoPreView:self.localView];
//    // 暂时测试使用，链接 IM
//    __weak typeof(self) weakSelf = self;
//
//    [[RongRTCEngine sharedEngine] joinRoom:self.roomId extra:self.targetId completion:^(RongRTCRoom * _Nullable room) {
//        self.room = room;
//        [weakSelf pushStream];
//    }];
    [self.cameraCapturer startRunning];
//    [self.mediaStream addAudioTrack:self.audioTrack];
//    [self.mediaStream addVideoTrack:self.videoTrack];
    [self.peerConnection addTrack:self.audioTrack streamIds:@[ kARDMediaStreamId ]];
    [self.peerConnection addTrack:self.videoTrack streamIds:@[ kARDMediaStreamId ]];
    RTCVideoTrack *track = (RTCVideoTrack *)([self videoTransceiver].receiver.track);
    [self.removeVideoView renderFrame:nil];
    [track addRenderer:self.removeVideoView];
    [self.peerConnection offerForConstraints:[self defaultOfferConstraints] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        if (!error) {
            [self.peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
                
            }];
            RTCSessionDescription* answer = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeAnswer sdp:sdp.sdp];
            [self.peerConnection setRemoteDescription:answer completionHandler:^(NSError * _Nullable error) {
                
            }];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Target Action
- (IBAction)switchCamera:(id)sender {
    [self.cameraCapturer switchCamera];
}

- (IBAction)exitAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Override
- (BOOL)shouldAutorotate {
    return NO;
}

#pragma makr - Helper
- (void)pushStream {
    
}

#pragma mark - RongCameraCapturerDelegate
- (void)didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    [self.localView renderSampleBuffer:sampleBuffer];
}

#pragma mark - Getter
- (GSRTCCameraCapturer*)cameraCapturer {
    if (!_cameraCapturer) {
        _cameraCapturer = [[GSRTCCameraCapturer alloc] initWithDelegate:self.videoSource];
        _cameraCapturer.delegate1 = self;
    }
    return _cameraCapturer;
}

- (RTCPeerConnectionFactory*)factory {
    if (!_factory) {
        RTCDefaultVideoDecoderFactory *decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
        RTCDefaultVideoEncoderFactory *encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];
        encoderFactory.preferredCodec = [[RTCVideoCodecInfo alloc] initWithName:@"H264"];
        _factory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:encoderFactory
                                                             decoderFactory:decoderFactory];
    }
    return _factory;
}

- (RTCPeerConnection*)peerConnection {
    if (!_peerConnection) {
        NSDictionary *optionalConstraints = @{ @"DtlsSrtpKeyAgreement" : @"false" };
        RTCMediaConstraints* constraints =
            [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil
                                                  optionalConstraints:optionalConstraints];
        RTCConfiguration *config = [[RTCConfiguration alloc] init];
        RTCCertificate *pcert = [RTCCertificate generateCertificateWithParams:@{
                                                                                @"expires" : @100000,
                                                                                @"name" : @"RSASSA-PKCS1-v1_5"
                                                                                }];
        RTCIceServer* server = [[RTCIceServer alloc]initWithURLStrings:@[@"stun:39.106.53.53:3478"] username:nil credential:nil];
        config.iceServers = @[server];
        config.sdpSemantics = RTCSdpSemanticsUnifiedPlan;
        config.certificate = pcert;
        
        _peerConnection = [self.factory peerConnectionWithConfiguration:config
                                                        constraints:constraints
                                                           delegate:self];
    }
    return _peerConnection;
}

- (RTCMediaConstraints *)defaultOfferConstraints {
    NSDictionary *mandatoryConstraints = @{
                                           @"OfferToReceiveAudio" : @"true",
                                           @"OfferToReceiveVideo" : @"true"
                                           };
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:mandatoryConstraints
     optionalConstraints:nil];
    return constraints;
}

- (RTCMediaStream*)mediaStream {
    if (!_mediaStream) {
        _mediaStream = [self.factory mediaStreamWithStreamId:@"roomid_userid_timestamp_random"];
    }
    return _mediaStream;
}


- (RTCVideoTrack*)videoTrack {
    if (!_videoTrack) {
        _videoTrack = [self.factory videoTrackWithSource:self.videoSource trackId:kARDVideoTrackId];
    }
    return _videoTrack;
}

- (RTCAudioTrack*)audioTrack {
    if (!_audioTrack) {
        _audioTrack = [self.factory audioTrackWithTrackId:kARDAudioTrackId];
    }
    return _audioTrack;
}

- (RTCVideoSource*)videoSource {
    if (!_videoSource) {
        _videoSource = [self.factory videoSource];
        //adaptOutputFormatToWidth 中参数必须设置,用于视频切割
        //        [_videoSource adaptOutputFormatToWidth:_adaptStreamVideoSize.width height:_adaptStreamVideoSize.height fps:(int)_videoFrame];
    }
    return _videoSource;
}

- (RTCAudioSource*)audioSource {
    if (_audioSource) {
        RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:@{} optionalConstraints:@{}];
        _audioSource = [self.factory audioSourceWithConstraints:constraints];
    }
    return _audioSource;
}

- (RTCRtpTransceiver *)videoTransceiver {
    for (RTCRtpTransceiver *transceiver in self.peerConnection.transceivers) {
        if (transceiver.mediaType == RTCRtpMediaTypeVideo) {
            return transceiver;
        }
    }
    return nil;
}



#pragma mark - RTCPeerConnectionDelegate
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeSignalingState:(RTCSignalingState)stateChanged {
    
}

/** Called when media is received on a new stream from remote peer. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection didAddStream:(RTCMediaStream *)stream {
    
}

/** Called when a remote peer closes a stream.
 *  This is not called when RTCSdpSemanticsUnifiedPlan is specified.
 */
- (void)peerConnection:(RTCPeerConnection *)peerConnection didRemoveStream:(RTCMediaStream *)stream {
    
}

/** Called when negotiation is needed, for example ICE has restarted. */
- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection {
    
}

/** Called any time the IceConnectionState changes. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeIceConnectionState:(RTCIceConnectionState)newState {
    
}

/** Called any time the IceGatheringState changes. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeIceGatheringState:(RTCIceGatheringState)newState {
    
}

/** New ice candidate has been found. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didGenerateIceCandidate:(RTCIceCandidate *)candidate {
    [peerConnection addIceCandidate:candidate];
}

/** Called when a group of local Ice candidates have been removed. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didRemoveIceCandidates:(NSArray<RTCIceCandidate *> *)candidates {
    
}

/** New data channel has been opened. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didOpenDataChannel:(RTCDataChannel *)dataChannel {
    
}

/** Called when signaling indicates a transceiver will be receiving media from
 *  the remote endpoint.
 *  This is only called with RTCSdpSemanticsUnifiedPlan specified.
 */

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didStartReceivingOnTransceiver:(RTCRtpTransceiver *)transceiver {
    
}

/** Called when a receiver and its track are created. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
        didAddReceiver:(RTCRtpReceiver *)rtpReceiver
               streams:(NSArray<RTCMediaStream *> *)mediaStreams {
    NSLog(@"💦💦💦💦💦mediaStream %@ streamid: %@",mediaStreams.firstObject,mediaStreams.firstObject.streamId);
    static BOOL addAlready = NO;
    if (addAlready) {
        return ;
    }
    self.videoTrack1 = mediaStreams.firstObject.videoTracks.firstObject;
    NSLog(@"💦💦💦💦💦 videoTrack: %@",self.videoTrack1);
    dispatch_async(dispatch_get_main_queue(), ^{
        addAlready = YES;
        [self.videoTrack1 removeRenderer:self.removeVideoView];
        [self.videoTrack1 addRenderer:self.removeVideoView];
    });
}

/** Called when the receiver and its track are removed. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
     didRemoveReceiver:(RTCRtpReceiver *)rtpReceiver {
    
}


@end
