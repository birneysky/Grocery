//
//  ViewController.m
//  BluetoothHFPRecorder
//
//  Created by birney on 2020/2/18.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


// A VP I/O unit's bus 1 connects to input hardware (microphone).
static const AudioUnitElement kInputBus = 1;
// A VP I/O unit's bus 0 connects to output hardware (speaker).
static const AudioUnitElement kOutputBus = 0;

// Try to use mono to save resources. Also avoids channel format conversion
// in the I/O audio unit. Initial tests have shown that it is possible to use
// mono natively for built-in microphones and for BT headsets but not for
// wired headsets. Wired headsets only support stereo as native channel format
// but it is a low cost operation to do a format conversion to mono in the
// audio unit. Hence, we will not hit a RTC_CHECK in
// VerifyAudioParametersForActiveAudioSession() for a mismatch between the
// preferred number of channels and the actual number of channels.

const int kRTCAudioSessionPreferredNumberOfChannels = 1;


const UInt32 kBytesPerSample = 2;


OSStatus OnGetPlayoutData(void* in_ref_con,
                          AudioUnitRenderActionFlags* flags,
                          const AudioTimeStamp* time_stamp,
                          UInt32 bus_number,
                          UInt32 num_frames,
                          AudioBufferList* io_data) {
    return noErr;
}


OSStatus OnDeliverRecordedData(void* in_ref_con,
                               AudioUnitRenderActionFlags* flags,
                               const AudioTimeStamp* time_stamp,
                               UInt32 bus_number,
                               UInt32 num_frames,
                               AudioBufferList* io_data) {
    //NSLog(@"num_frames:%@", @(num_frames));
    Byte buffer[4096] = {};
    AudioBufferList outList;
    outList.mNumberBuffers = 1;
    outList.mBuffers[0].mData = buffer;
    outList.mBuffers[0].mDataByteSize = num_frames * 2;
    outList.mBuffers[0].mNumberChannels = 1;
    AudioUnit unit = in_ref_con;
    AudioUnitRender(unit, flags, time_stamp, bus_number, num_frames, &outList);
    
    /***************************** for debug***************************/
    int bytesCount = outList.mBuffers[0].mDataByteSize;
    printf("\n====================== \n");
    for (int i = 0; i < bytesCount; i++) {
        Byte* pBytes = (Byte*)buffer;
        printf("%0.2x,", *pBytes);
    }
    printf("\n======================= \n");

    return noErr;
                                               
}


enum CommonPCMFormat {
    kPCMFormatOther        = 0,
    kPCMFormatFloat32    = 1,
    kPCMFormatInt16        = 2,
    kPCMFormatFixed824    = 3,
    kPCMFormatFloat64    = 4,
    kPCMFormatInt32        = 5
};

AudioStreamBasicDescription formatDescription(double inSampleRate, UInt32 inNumChannels, enum CommonPCMFormat pcmf, bool inIsInterleaved) {
    unsigned wordsize;
    AudioStreamBasicDescription format;
    format.mSampleRate = inSampleRate;
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    format.mFramesPerPacket = 1;
    format.mChannelsPerFrame = inNumChannels;
    format.mBytesPerFrame = format.mBytesPerPacket = 0;
    format.mReserved = 0;

    switch (pcmf) {
    case kPCMFormatFloat32:
        wordsize = 4;
        format.mFormatFlags |= kAudioFormatFlagIsFloat;
        break;
    case kPCMFormatFloat64:
        wordsize = 8;
        format.mFormatFlags |= kAudioFormatFlagIsFloat;
        break;
    case kPCMFormatInt16:
        wordsize = 2;
        format.mFormatFlags |= kAudioFormatFlagIsSignedInteger;
        break;
    case kPCMFormatInt32:
        wordsize = 4;
        format.mFormatFlags |= kAudioFormatFlagIsSignedInteger;
        break;
    case kPCMFormatFixed824:
        wordsize = 4;
        format.mFormatFlags |= kAudioFormatFlagIsSignedInteger | (24 << kLinearPCMFormatFlagsSampleFractionShift);
        break;
    }
    format.mBitsPerChannel = wordsize * 8;
    if (inIsInterleaved)
        format.mBytesPerFrame = format.mBytesPerPacket = wordsize * inNumChannels;
    else {
        format.mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
        format.mBytesPerFrame = format.mBytesPerPacket = wordsize;
    }
    return format;
}

AudioStreamBasicDescription audioFormatFor(Float64 sample_rate)  {
  // Set the application formats for input and output:
  // - use same format in both directions
  // - avoid resampling in the I/O unit by using the hardware sample rate
  // - linear PCM => noncompressed audio data format with one frame per packet
  // - no need to specify interleaving since only mono is supported
  AudioStreamBasicDescription format;
  format.mSampleRate = sample_rate;
  format.mFormatID = kAudioFormatLinearPCM;
  format.mFormatFlags =
      kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsNonInterleaved;
  format.mBytesPerPacket = kBytesPerSample;
  format.mFramesPerPacket = 1;  // uncompressed.
  format.mBytesPerFrame = kBytesPerSample;
  format.mChannelsPerFrame = kRTCAudioSessionPreferredNumberOfChannels;
  format.mBitsPerChannel = 8 * kBytesPerSample;
  return format;
}


@interface ViewController ()

@end

@implementation ViewController {
    AudioComponentInstance vpio_unit_;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRouteChange:)
                                                 name:AVAudioSessionRouteChangeNotification object:nil];
    AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    /// ios13 中 不设置 bufferDuration，应用在后台时，蓝牙耳机接入是，OnDeliverRecordedData 回调停止调用，这个问题很奇怪，并且在后台模式下，重启 audiounit 会失败
    NSTimeInterval bufferDuration = .005;
    [sessionInstance setPreferredIOBufferDuration:bufferDuration error:nil];
    [sessionInstance setPreferredSampleRate:44100 error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self setup:44100];
    
    
}

#pragma mark - Helpers
- (BOOL)setup:(Float64)sample_rate {
    // Create an audio component description to identify the Voice Processing
    // I/O audio unit.
    AudioComponentDescription vpio_unit_description;
    vpio_unit_description.componentType = kAudioUnitType_Output;
    vpio_unit_description.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
    vpio_unit_description.componentManufacturer = kAudioUnitManufacturer_Apple;
    vpio_unit_description.componentFlags = 0;
    vpio_unit_description.componentFlagsMask = 0;

    // Obtain an audio unit instance given the description.
    AudioComponent found_vpio_unit_ref = AudioComponentFindNext(nil, &vpio_unit_description);

    // Create a Voice Processing IO audio unit.
    OSStatus result = noErr;
    result = AudioComponentInstanceNew(found_vpio_unit_ref, &vpio_unit_);
    if (result != noErr) {
      vpio_unit_ = nil;
      NSLog(@"AudioComponentInstanceNew failed. Error=%ld.", (long)result);
      return NO;
    }

    // Enable input on the input scope of the input element.
    UInt32 enable_input = 1;
    result = AudioUnitSetProperty(vpio_unit_,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &enable_input,
                                  sizeof(enable_input));
    if (result != noErr) {
      //DisposeAudioUnit();
      NSLog(@"Failed to enable input on input scope of input element. "
            "Error=%ld.",
            (long)result);
      return NO;
    }

    // Enable output on the output scope of the output element.
    UInt32 enable_output = 1;
    result = AudioUnitSetProperty(vpio_unit_,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &enable_output,
                                  sizeof(enable_output));
    if (result != noErr) {
      //DisposeAudioUnit();
      NSLog(@"Failed to enable output on output scope of output element. "
            "Error=%@.",
            @(result));
      return NO;
    }
    
//    AudioStreamBasicDescription format = formatDescription(sample_rate, 1, kPCMFormatFloat32, false);
//    UInt32 size = sizeof(format);
//    result = AudioUnitSetProperty(vpio_unit_,
//                                  kAudioUnitProperty_StreamFormat,
//                                  kAudioUnitScope_Output,
//                                  kInputBus, &format, size);
//    if (result != noErr) {
//        NSLog(@"Failed to set format on output scope of input bus. "
//              "Error=%ld.",
//              (long)result);
//        return NO;
//    }
//
//    result = AudioUnitSetProperty(vpio_unit_,
//                                  kAudioUnitProperty_StreamFormat,
//                                  kAudioUnitScope_Input,
//                                  kOutputBus,
//                                  &format,
//                                  size);
//    if (result != noErr) {
//        NSLog(@"Failed to set format on input scope of output bus. "
//              "Error=%ld.",
//              (long)result);
//        return NO;
//    }
    
//    UInt32 maximumFramesPerSlice = 4096;
//    result = AudioUnitSetProperty (vpio_unit_,
//                                   kAudioUnitProperty_MaximumFramesPerSlice,
//                                   kAudioUnitScope_Global,
//                                   0,
//                                   &maximumFramesPerSlice,
//                                   sizeof (maximumFramesPerSlice)
//                              );
//    if (result != noErr) {
//        NSLog(@"couldn't set max frames per slice on vocice processing IO");
//        return NO;
//    }
    

    
    AURenderCallbackStruct input_callback;
    input_callback.inputProc = OnDeliverRecordedData;
    input_callback.inputProcRefCon = vpio_unit_;
    result = AudioUnitSetProperty(vpio_unit_,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global, kInputBus,
                                  &input_callback, sizeof(input_callback));
    if (result != noErr) {
      //DisposeAudioUnit();
      NSLog(@"Failed to specify the input callback on the input bus. "
                   "Error=%ld.",
                  (long)result);
      return NO;
    }
    


    // Specify the callback function that provides audio samples to the audio
    // unit.
//    AURenderCallbackStruct render_callback;
//    render_callback.inputProc = OnGetPlayoutData;
//    render_callback.inputProcRefCon = vpio_unit_;
//    result = AudioUnitSetProperty(
//        vpio_unit_, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input,
//        kOutputBus, &render_callback, sizeof(render_callback));
//    if (result != noErr) {
//      //DisposeAudioUnit();
//      NSLog(@"Failed to specify the render callback on the output bus. "
//                   "Error=%ld.",
//                  (long)result);
//      return NO;
//    }

    // Disable AU buffer allocation for the recorder, we allocate our own.
    // TODO(henrika): not sure that it actually saves resource to make this call.
//    UInt32 flag = 0;
//    result = AudioUnitSetProperty(
//        vpio_unit_, kAudioUnitProperty_ShouldAllocateBuffer,
//        kAudioUnitScope_Output, kInputBus, &flag, sizeof(flag));
//    if (result != noErr) {
//      //DisposeAudioUnit();
//      NSLog(@"Failed to disable buffer allocation on the input bus. "
//                   "Error=%ld.",
//                  (long)result);
//      return NO;
//    }

    // Specify the callback to be called by the I/O thread to us when input audio
    // is available. The recorded samples can then be obtained by calling the
    // AudioUnitRender() method.

    
    
    
      AudioStreamBasicDescription format = audioFormatFor(sample_rate);
      UInt32 size = sizeof(format);

       //Set the format on the output scope of the input element/bus.
      result =
          AudioUnitSetProperty(vpio_unit_, kAudioUnitProperty_StreamFormat,
                               kAudioUnitScope_Output, kInputBus, &format, size);
      if (result != noErr) {
        NSLog(@"Failed to set format on output scope of input bus. "
                     "Error=%ld.",
                    (long)result);
        return NO;
      }

      // Set the format on the input scope of the output element/bus.
//      result =
//          AudioUnitSetProperty(vpio_unit_, kAudioUnitProperty_StreamFormat,
//                               kAudioUnitScope_Input, kOutputBus, &format, size);
//      if (result != noErr) {
//        NSLog(@"Failed to set format on input scope of output bus. "
//                     "Error=%ld.",
//                    (long)result);
//        return false;
//      }
    
//    // 设置AudioUnitRender()函数在处理输入数据时，最大的输入吞吐量
//    UInt32 maximumFramesPerSlice = 4096;
//    AudioUnitSetProperty (
//                          vpio_unit_,
//                          kAudioUnitProperty_MaximumFramesPerSlice,
//                          kAudioUnitScope_Global,
//                          0,
//                          &maximumFramesPerSlice,
//                          sizeof (maximumFramesPerSlice)
//                          );

      // Initialize the Voice Processing I/O unit instance.
      // Calls to AudioUnitInitialize() can fail if called back-to-back on
      // different ADM instances. The error message in this case is -66635 which is
      // undocumented. Tests have shown that calling AudioUnitInitialize a second
      // time, after a short sleep, avoids this issue.
      // See webrtc:5166 for details.
      int failed_initalize_attempts = 0;
      result = AudioUnitInitialize(vpio_unit_);

    if(result != noErr) {
       NSLog(@"Failed to initialize the Voice Processing I/O unit. "
                    "Error=%ld.",
                   (long)result);
        return NO;
    }
    
    return YES;
}

- (void)teardown {
    if (vpio_unit_) {
        AudioUnitUninitialize(vpio_unit_);
        vpio_unit_ = nil;
    }
}

- (BOOL)start {
    OSStatus result = AudioOutputUnitStart(vpio_unit_);
    if (result != noErr) {
      NSLog(@"Failed to start audio unit. Error=%ld", (long)result);
      return NO;
    } else {
      NSLog(@"Started audio unit");
    }
    return YES;
}

- (BOOL)stop {
    OSStatus result = AudioOutputUnitStop(vpio_unit_);
    if (result != noErr) {
      NSLog(@"Failed to stop audio unit. Error=%ld", (long)result);
      return NO;
    } else {
      NSLog(@"Stopped audio unit");
    }

    return YES;
}

#pragma mark - Target Action

- (IBAction)startStopAction:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"Start"]) {
        [self start];
        sender.title = @"Stop";
    } else {
        [self stop];
        sender.title = @"Start";
    }
}

#pragma mark - notification selector
- (void)handleRouteChange:(NSNotification*)notification {
    NSLog(@"routeChange:%@",notification);
    NSInteger reason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] intValue];
//    if (1 == reason) {
//        [self teardown];
//        [self setup:[AVAudioSession sharedInstance].sampleRate];
//        [self start];
//    }
}

@end
