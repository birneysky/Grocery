//
//  AVAudioEngineTests.swift
//  AudioEngineTests
//
//  Created by birney on 2020/2/28.
//  Copyright © 2020 Pea. All rights reserved.
//

import XCTest
import AVFoundation

func printASBD(asbd: UnsafePointer<AudioStreamBasicDescription>)  {
 
    //char formatIDString[5];
    let aasbd = asbd.pointee;
    var formatID = CFSwapInt32HostToBig (aasbd.mFormatID);
    let formatIDRaw = UnsafeMutableRawPointer.allocate(byteCount: 5, alignment: 0);
    //formatIDString.initializeMemory(as: Int8, from: nil, count: 5)
    bcopy (&formatID, formatIDRaw, 4);
    //formatIDString[4] = '\0';
    //let formatIDString = String(cString: formatIDRaw)
 
    NSLog ("  Sample Rate:         %10.0f",  aasbd.mSampleRate)
    //NSLog ("  Format ID:           %@",    formatIDString);
    NSLog ("  Format Flags:        %10X",    aasbd.mFormatFlags);
    NSLog ("  Bytes per Packet:    %10d",    aasbd.mBytesPerPacket);
    NSLog ("  Frames per Packet:   %10d",    aasbd.mFramesPerPacket);
    NSLog ("  Bytes per Frame:     %10d",    aasbd.mBytesPerFrame);
    NSLog ("  Channels per Frame:  %10d",    aasbd.mChannelsPerFrame);
    NSLog ("  Bits per Channel:    %10d",    aasbd.mBitsPerChannel);
}

class AVAudioEngineTests: XCTestCase {

    let engine = AVAudioEngine()
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    


    func testEnineNumberOfBus() {
        let input = engine.inputNode
        XCTAssertEqual(input.numberOfInputs, 1);
        XCTAssertEqual(input.numberOfOutputs, 1)
        
        let output = engine.outputNode
        XCTAssertEqual(output.numberOfInputs, 1);
        XCTAssertEqual(output.numberOfOutputs, 1)
    }
    func testEngineInputNodeFormat() {
        let input = engine.inputNode
        let format = input.inputFormat(forBus: 1)
        print("inputNode format:\(format)")
        printASBD(asbd: format.streamDescription)
        
        guard let tempFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                                 sampleRate: AVAudioSession.sharedInstance().sampleRate,
                                                 channels: AVAudioChannelCount(1),
                                          interleaved: false) else {fatalError() }
        
         printASBD(asbd: tempFormat.streamDescription)
    }
    
    func testEngineVoiceProcessingIONodes() {
        let input = engine.inputNode
        do {
            try input.setVoiceProcessingEnabled(true)
        } catch {
        }
        print("input unit desc:\(input.auAudioUnit.componentDescription)")
        print("input unit componentName:\(input.auAudioUnit.componentName ?? "unknow")")
        print("input unit audioUnitName:\(input.auAudioUnit.audioUnitName ?? "unknow")")
        print("input unit component:\(input.auAudioUnit.component)")
        print("input unit audio_unit:\(String(describing: input.audioUnit))")
        print("input unit auaudio_unit:\(String(describing: input.auAudioUnit))")
        print("input unit input enabled:\(input.auAudioUnit.isInputEnabled)")
        print("input unit output enabled:\(input.auAudioUnit.isOutputEnabled)")

        XCTAssertEqual(input.auAudioUnit.componentDescription.componentType, kAudioUnitType_Output)
        XCTAssertEqual(input.auAudioUnit.componentDescription.componentSubType, kAudioUnitSubType_VoiceProcessingIO)
        XCTAssertEqual(input.auAudioUnit.componentDescription.componentManufacturer, kAudioUnitManufacturer_Apple)

        let output = engine.outputNode
        print("output unit desc:\(output.auAudioUnit.componentDescription)")
        print("output unit componentName:\(output.auAudioUnit.componentName ?? "unknow")")
        print("output unit audioUnitName:\(output.auAudioUnit.audioUnitName ?? "unknow")")
        print("output unit component:\(output.auAudioUnit.component)")
        print("output unit audio_unit:\(String(describing: output.audioUnit))")
        print("output unit auaudio_unit:\(String(describing: output.auAudioUnit))")
        print("output unit input enabled:\(output.auAudioUnit.isInputEnabled)")
        print("output unit output enabled:\(output.auAudioUnit.isOutputEnabled)")

        XCTAssertEqual(output.auAudioUnit.componentDescription.componentType, kAudioUnitType_Output)
        XCTAssertEqual(output.auAudioUnit.componentDescription.componentSubType, kAudioUnitSubType_VoiceProcessingIO)
        XCTAssertEqual(output.auAudioUnit.componentDescription.componentManufacturer, kAudioUnitManufacturer_Apple)


        XCTAssertNotEqual(input, output)
        XCTAssertEqual(input.audioUnit, output.audioUnit);
        XCTAssertEqual(input.auAudioUnit, output.auAudioUnit)
        XCTAssertEqual(input.auAudioUnit.audioUnitName, output.auAudioUnit.audioUnitName)
    }
    
    func testEngineInputAndOutputNode() {
        let input = engine.inputNode
        print("input unit desc:\(input.auAudioUnit.componentDescription)")
        print("input unit componentName:\(input.auAudioUnit.componentName ?? "unknow")")
        print("input unit audioUnitName:\(input.auAudioUnit.audioUnitName ?? "unknow")")
        print("input unit component:\(input.auAudioUnit.component)")
        print("input unit audio_unit:\(String(describing: input.audioUnit))")
        print("input unit auaudio_unit:\(String(describing: input.auAudioUnit))")
        print("input unit input enabled:\(input.auAudioUnit.isInputEnabled)")
        print("input unit output enabled:\(input.auAudioUnit.isOutputEnabled)")

        XCTAssertEqual(input.auAudioUnit.componentDescription.componentType, kAudioUnitType_Output)
        XCTAssertEqual(input.auAudioUnit.componentDescription.componentSubType, kAudioUnitSubType_RemoteIO)
        XCTAssertEqual(input.auAudioUnit.componentDescription.componentManufacturer, kAudioUnitManufacturer_Apple)

        let output = engine.outputNode
        print("output unit desc:\(output.auAudioUnit.componentDescription)")
        print("output unit componentName:\(output.auAudioUnit.componentName ?? "unknow")")
        print("output unit audioUnitName:\(output.auAudioUnit.audioUnitName ?? "unknow")")
        print("output unit component:\(output.auAudioUnit.component)")
        print("output unit audio_unit:\(String(describing: output.audioUnit))")
        print("output unit auaudio_unit:\(String(describing: output.auAudioUnit))")
        print("output unit input enabled:\(output.auAudioUnit.isInputEnabled)")
        print("output unit output enabled:\(output.auAudioUnit.isOutputEnabled)")
        
        XCTAssertEqual(output.auAudioUnit.componentDescription.componentType, kAudioUnitType_Output)
        XCTAssertEqual(output.auAudioUnit.componentDescription.componentSubType, kAudioUnitSubType_RemoteIO)
        XCTAssertEqual(output.auAudioUnit.componentDescription.componentManufacturer, kAudioUnitManufacturer_Apple)
        
        
        XCTAssertNotEqual(input, output)
        XCTAssertEqual(input.audioUnit, output.audioUnit);
        XCTAssertEqual(input.auAudioUnit, output.auAudioUnit)
        XCTAssertEqual(input.auAudioUnit.audioUnitName, output.auAudioUnit.audioUnitName)
        
    }

    func testAVAudioInputNode() {
        print("Subtype_RemoteIO: \(kAudioUnitSubType_RemoteIO)")
        print("Subtype_voiceIO: \(kAudioUnitSubType_VoiceProcessingIO)")
        print("UnitType_Ouput:\(kAudioUnitType_Output)")
        
        let input = engine.inputNode
        print("input unit desc:\(input.auAudioUnit.componentDescription)")
        print("input unit componentName:\(input.auAudioUnit.componentName ?? "unknow")")
        print("input unit audioUnitName:\(input.auAudioUnit.audioUnitName ?? "unknow")")
        print("input unit component:\(input.auAudioUnit.component)")
        print("input unit audio_unit:\(String(describing: input.audioUnit))")
        print("output unit auaudio_unit:\(String(describing: input.auAudioUnit))")
        
        XCTAssertEqual(input.auAudioUnit.componentDescription.componentType, kAudioUnitType_Output)
        XCTAssertEqual(input.auAudioUnit.componentDescription.componentSubType, kAudioUnitSubType_RemoteIO)
        XCTAssertEqual(input.auAudioUnit.componentDescription.componentManufacturer, kAudioUnitManufacturer_Apple)
        
        do {
            try input.setVoiceProcessingEnabled(true);
        } catch {
              print("could not enabled voice processing \(error)")
        }
        print("=====================================")
        print("input unit desc:\(input.auAudioUnit.componentDescription)")
        print("input unit componentName:\(input.auAudioUnit.componentName ?? "unknow")")
        print("input unit audioUnitName:\(input.auAudioUnit.audioUnitName ?? "unknow")")
        print("input unit component:\(input.auAudioUnit.component)")
        print("input unit audio_unit:\(String(describing: input.audioUnit))")
        print("output unit auaudio_unit:\(String(describing: input.auAudioUnit))")
        print("input unit number of inputs:\(input.numberOfInputs)")
        print("input unit number of inputs:\(input.numberOfOutputs)")
        print("input unit input enabled:\(input.auAudioUnit.isInputEnabled)")
        print("input unit output enabled:\(input.auAudioUnit.isOutputEnabled)")
        
        XCTAssertEqual(input.auAudioUnit.componentDescription.componentType, kAudioUnitType_Output)
        XCTAssertEqual(input.auAudioUnit.componentDescription.componentSubType, kAudioUnitSubType_VoiceProcessingIO)
        XCTAssertEqual(input.auAudioUnit.componentDescription.componentManufacturer, kAudioUnitManufacturer_Apple)
    }
    
    func testAVAudioOutputNode() {
        print("Subtype_RemoteIO: \(kAudioUnitSubType_RemoteIO)")
        print("Subtype_voiceIO: \(kAudioUnitSubType_VoiceProcessingIO)")
        print("UnitType_Ouput:\(kAudioUnitType_Output)")
        
        let output = engine.outputNode
        print("output unit desc:\(output.auAudioUnit.componentDescription)")
        print("output unit componentName:\(output.auAudioUnit.componentName ?? "unknow")")
        print("output unit audioUnitName:\(output.auAudioUnit.audioUnitName ?? "unknow")")
        print("output unit component:\(output.auAudioUnit.component)")
        print("output unit audio_unit:\(String(describing: output.audioUnit))")
        print("output unit auaudio_unit:\(String(describing: output.auAudioUnit))")
        print("output unit input enabled:\(output.auAudioUnit.isInputEnabled)")
        print("output unit output enabled:\(output.auAudioUnit.isOutputEnabled)")
        
        XCTAssertEqual(output.auAudioUnit.componentDescription.componentType, kAudioUnitType_Output)
        XCTAssertEqual(output.auAudioUnit.componentDescription.componentSubType, kAudioUnitSubType_RemoteIO)
        XCTAssertEqual(output.auAudioUnit.componentDescription.componentManufacturer, kAudioUnitManufacturer_Apple)
    }
    
    func testAVAudioPlayerNode() {
        print("Subtype_RemoteIO: \(kAudioUnitSubType_RemoteIO)")
        print("Subtype_voiceIO: \(kAudioUnitSubType_VoiceProcessingIO)")
        print("UnitType_Ouput:\(kAudioUnitType_Output)")
        print("SubType_ScheduledSoundPlayer:\(kAudioUnitSubType_ScheduledSoundPlayer)")
        let playerNode = AVAudioPlayerNode()
        print("playerNode unit desc:\(playerNode.auAudioUnit.componentDescription)")
        print("playerNode unit componentName:\(playerNode.auAudioUnit.componentName ?? "unknow")")
        print("playerNode unit audioUnitName:\(playerNode.auAudioUnit.audioUnitName ?? "unknow")")
        print("playerNode unit component:\(playerNode.auAudioUnit.component)")
        print("playerNode unit auaudio_unit:\(String(describing: playerNode.auAudioUnit))")
        
        //print("output unit input enabled:\(playerNode.auAudioUnit.isInputEnabled)")
        //print("output unit output enabled:\(playerNode.auAudioUnit.isOutputEnabled)")
        XCTAssertEqual(playerNode.auAudioUnit.componentDescription.componentType, kAudioUnitType_Generator)
        XCTAssertEqual(playerNode.auAudioUnit.componentDescription.componentSubType, kAudioUnitSubType_ScheduledSoundPlayer)
        XCTAssertEqual(playerNode.auAudioUnit.componentDescription.componentManufacturer, kAudioUnitManufacturer_Apple)
    }
    
    func testAVAudioMixerNode() {
        let mixer = AVAudioMixerNode()
        print("playerNode unit desc:\(mixer.auAudioUnit.componentDescription)")
        print("playerNode unit componentName:\(mixer.auAudioUnit.componentName ?? "unknow")")
        print("playerNode unit audioUnitName:\(mixer.auAudioUnit.audioUnitName ?? "unknow")")
        print("playerNode unit component:\(mixer.auAudioUnit.component)")
        print("playerNode unit auaudio_unit:\(String(describing: mixer.auAudioUnit))")
               
    }
    
    func testAVAudioType() {
        print("UnitType_Ouput:\(kAudioUnitType_Output)")
        
        print("UnitType_MusicDevice:\(kAudioUnitType_MusicDevice)")
        print("UnitType_MusicEffect:\(kAudioUnitType_MusicEffect)")
        print("UnitType_FormatConverter:\(kAudioUnitType_FormatConverter)")
        print("UnitType_Effect:\(kAudioUnitType_Effect)")
        print("UnitType_Mixer:\(kAudioUnitType_Mixer)")
        print("UnitType_Panner:\(kAudioUnitType_Panner)")
        print("UnitType_Generator:\(kAudioUnitType_Generator)")
        print("UnitType_OfflineEffect:\(kAudioUnitType_OfflineEffect)")
        print("UnitType_MIDIProcessor:\(kAudioUnitType_MIDIProcessor)")

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
