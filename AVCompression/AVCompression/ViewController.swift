//
//  ViewController.swift
//  AVCompression
//
//  Created by birney on 2018/1/31.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class ViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        let path = Bundle.main.bundlePath + "/ScreenRecording.m4v"
        compressVideo(atUrl: URL(fileURLWithPath: path))
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func compressVideo(atUrl:URL) {
        let interval = Int64(NSDate().timeIntervalSince1970 * 1000)
        let outputPath = String(format: "%@%lld.mp4", arguments: [NSTemporaryDirectory(),interval])
        NSLog("%@", outputPath)
        let asset = AVAsset(url: atUrl)
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)
        print(exportSession?.supportedFileTypes ?? "nil")
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.outputURL = URL(fileURLWithPath: outputPath)
        exportSession?.outputFileType = AVFileType.mp4
        let sourceTimer = DispatchSource.makeTimerSource()
        sourceTimer.setEventHandler {
            NSLog("progress %f", exportSession!.progress)
        }
        sourceTimer.schedule(deadline: DispatchTime.now(), repeating: 0.25)
        exportSession?.exportAsynchronously(completionHandler: {
            NSLog("stauts %d", exportSession!.status.rawValue)
            sourceTimer.cancel()
        });
        sourceTimer.resume()
        
    }

    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        let path = Bundle.main.bundlePath + "/test.mp4"
        let assetL = ALAssetsLibrary()
        let videoUrl = URL(fileURLWithPath: path)
        if assetL.videoAtPathIs(compatibleWithSavedPhotosAlbum: videoUrl) {
            assetL.writeVideoAtPath(toSavedPhotosAlbum: videoUrl) { (assertUrl, error) in
                print("assertUrl %@", assertUrl ?? "nil")
            }
        }
    }
    
}

