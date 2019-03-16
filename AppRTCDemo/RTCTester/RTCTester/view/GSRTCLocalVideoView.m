//
//  RCLocalPreviewView.m
//  RongRTCLib
//
//  Created by zhaobingdong on 2018/12/17.
//  Copyright © 2018年 Bailing Cloud. All rights reserved.
//

#import "GSRTCLocalVideoView.h"

@interface GSRTCLocalVideoView ()

@property (nonatomic,weak) AVSampleBufferDisplayLayer* disPlaylayer;
@end


@implementation GSRTCLocalVideoView

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

+(Class)layerClass {
    return [AVSampleBufferDisplayLayer class];
}

-(void)renderSampleBuffer:(CMSampleBufferRef)sample {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self.disPlaylayer flush];
        return;
    }
    if (self.disPlaylayer.isReadyForMoreMediaData) {
        //CFRetain(sample);
        [self.disPlaylayer enqueueSampleBuffer:sample];
        //rCFRelease(sample);
    }
}

- (void)setup {
    self.disPlaylayer = (AVSampleBufferDisplayLayer*)self.layer;
    self.disPlaylayer.backgroundColor = [UIColor blackColor].CGColor;
}

- (void)setFilleMode:(RCVideoFillMode)filleMode {
    if (RCVideoFillModeAspect == filleMode) {
        self.disPlaylayer.videoGravity = AVLayerVideoGravityResizeAspect;
    } else {
        self.disPlaylayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
}

- (void)setFrame:(CGRect)frame {
    if (frame.origin.y == -161) {
         [super setFrame:frame];
    } else {
        [super setFrame:frame];
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

@end
