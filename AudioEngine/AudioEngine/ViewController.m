//
//  ViewController.m
//  AudioEngine
//
//  Created by birney on 2020/2/27.
//  Copyright © 2020 rongcloud. All rights reserved.
//

@import AVFoundation;
#import "ViewController.h"
#import "GSAudioEngine.h"
#import "GSAudioMixerNode.h"
#import "GSAudioOutputNode.h"
#import "GSAudioPlayerNode.h"
#import "GSAudioInputNode.h"

@interface ViewController ()


@property (nonatomic, strong) GSAudioEngine* engine;
@property (nonatomic, strong) GSAudioMixerNode* mixer;
@property (nonatomic, strong) GSAudioPlayerNode* player1;
@property (nonatomic, strong) GSAudioPlayerNode* player2;
@property (nonatomic, strong) GSAudioOutputNode* outputNode;

@end

@implementation ViewController

#pragma mark - init

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureAudioSession];
    [self.engine attach:self.player1];
    [self.engine attach:self.mixer];
    [self.engine attach:self.player2];
    [self.engine attach:self.outputNode];
    //self.engine.inputNode;
    [self.engine connect:self.player1 to:self.mixer];
    [self.engine connect:self.player2 to:self.mixer];
    //[self.engine connect:self.inputNode to:self.mixer];
    [self.engine connect:self.mixer to:self.outputNode];
        
    [self.engine prepare];
    
}

#pragma mark - Helper
- (void)configureAudioSession {
    AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [sessionInstance setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];

    NSTimeInterval bufferDuration = .005;
    [sessionInstance setPreferredIOBufferDuration:bufferDuration error:&error];

    [sessionInstance setPreferredSampleRate:44100 error:&error];
    [sessionInstance setActive:YES error:&error];

    
}

#pragma mark - tareget actions

- (IBAction)switchSpeaker:(UIButton *)sender {
    if (!sender.isSelected) {
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        sender.selected = YES;
    } else {
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        sender.selected = NO;
    }
}
- (IBAction)startAction:(UIButton *)sender {
    if (!sender.isSelected) {
        [self.engine start];
        sender.selected = YES;
    } else {
        [self.engine stop];
        sender.selected = NO;
    }
}
- (IBAction)player1SwithPress:(UISwitch *)sender {
    if (sender.on) {
        [self.player1 play];
    } else {
        [self.player1 pause];
    }
}
- (IBAction)player2SwitchPress:(UISwitch *)sender {
    if (sender.on) {
        [self.player2 play];
    } else {
        [self.player2 pause];
    }
}

- (IBAction)alterPlayer1Volume:(UISlider *)sender {
    self.player1.inputVolume = sender.value;
}

- (IBAction)alterPlayer2Volume:(UISlider*)sender {
    self.player2.inputVolume = sender.value;
}

#pragma mark - Getters
- (GSAudioEngine*) engine {
    if (!_engine) {
        _engine = [[GSAudioEngine alloc] init];
    }
    return _engine;
}

- (GSAudioMixerNode*)mixer {
    if (!_mixer) {
        _mixer = [[GSAudioMixerNode alloc] init];
    }
    return _mixer;
}

- (GSAudioPlayerNode*)player1 {
    if (!_player1) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"guitar" ofType:@"m4a"];
        NSURL* fileUrl = [NSURL fileURLWithPath:path];
        _player1 = [[GSAudioPlayerNode alloc] initWithFileURL:fileUrl];
    }
    return _player1;
}


- (GSAudioPlayerNode*)player2 {
    if (!_player2) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"band" ofType:@"m4a"];
        NSURL* fileUrl = [NSURL fileURLWithPath:path];
        _player2 = [[GSAudioPlayerNode alloc] initWithFileURL:fileUrl];
    }
    return _player2;
}

- (GSAudioOutputNode*)outputNode {
    if (!_outputNode) {
        _outputNode = [[GSAudioOutputNode alloc] init];
    }
    return _outputNode;
}

@end
