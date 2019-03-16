//
//  RCRemoteVideoView.m
//  RongRTCLib
//
//  Created by zhaobingdong on 2018/12/17.
//  Copyright © 2018年 Bailing Cloud. All rights reserved.
//

#import "GSRTCRemoteVideoView.h"
#import "GSRTCRemoteVideoView+Private.h"

@interface GSRTCRemoteVideoView ()

@property (nonatomic,strong) RTCEAGLVideoView* eaglView;
@end

@implementation GSRTCRemoteVideoView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addSubview:self.eaglView];
    [self strechToSuperview:self.eaglView];
}

- (void)dealloc
{
    self.eaglView = nil;
}

- (void)setFilleMode:(RCVideoFillMode)filleMode {
    if (RCVideoFillModeAspect == filleMode) {
        self.eaglView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        self.eaglView.contentMode = UIViewContentModeScaleAspectFill;
    }
}

#pragma mark - Helper
- (void)strechToSuperview:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *formats = @[ @"H:|[view]|", @"V:|[view]|" ];
    for (NSString *each in formats) {
        NSArray *constraints =
        [NSLayoutConstraint constraintsWithVisualFormat:each options:0 metrics:nil views:@{@"view" : view}];
        [view.superview addConstraints:constraints];
    }
}

#pragma mark - Getters
- (RTCEAGLVideoView*)eaglView {
    if (!_eaglView) {
        _eaglView = [[RTCEAGLVideoView alloc] initWithFrame:self.bounds];
        _eaglView.contentMode = UIViewContentModeScaleAspectFit;
//        _eaglView.delegate = ??? //上报分辨率delegate
    }
    return _eaglView;
}

#pragma mark - RTCEAGLVideoViewDelegate
- (void)videoView:(RTCEAGLVideoView *)videoView didChangeVideoSize:(CGSize)size
{
    //用户关键帧,远端视频分辨率,即:宽高比
    if (videoView == _eaglView)
    {
        
    }
}

@end
