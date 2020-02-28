//
//  AVAudioEngineTests.swift
//  AudioEngineTests
//
//  Created by birney on 2020/2/28.
//  Copyright © 2020 rongcloud. All rights reserved.
//

import XCTest
import AVFoundation

class AVAudioEngineTests: XCTestCase {

    let engine = AVAudioEngine()
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
        print("output unit desc:\(playerNode.auAudioUnit.componentDescription)")
        print("output unit componentName:\(playerNode.auAudioUnit.componentName ?? "unknow")")
        print("output unit audioUnitName:\(playerNode.auAudioUnit.audioUnitName ?? "unknow")")
        print("output unit component:\(playerNode.auAudioUnit.component)")
        print("output unit auaudio_unit:\(String(describing: playerNode.auAudioUnit))")
        //print("output unit input enabled:\(playerNode.auAudioUnit.isInputEnabled)")
        //print("output unit output enabled:\(playerNode.auAudioUnit.isOutputEnabled)")
        XCTAssertEqual(playerNode.auAudioUnit.componentDescription.componentType, kAudioUnitType_Generator)
        XCTAssertEqual(playerNode.auAudioUnit.componentDescription.componentSubType, kAudioUnitSubType_ScheduledSoundPlayer)
        XCTAssertEqual(playerNode.auAudioUnit.componentDescription.componentManufacturer, kAudioUnitManufacturer_Apple)
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
