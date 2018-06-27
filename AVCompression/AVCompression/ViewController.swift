//
//  ViewController.swift
//  AVCompression
//
//  Created by birney on 2018/1/31.
//  Copyright © 2018年 RongCloud. All rights reserved.
//

import UIKit
import AVFoundation

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
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.outputURL = URL(fileURLWithPath: outputPath)
        exportSession?.outputFileType = AVFileType.mp4
        let timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { (_) in
            NSLog("progress %f", exportSession!.progress)
        }
        exportSession?.exportAsynchronously(completionHandler: {
            NSLog("stauts %d", exportSession!.status.rawValue)
            timer.invalidate()
        });
        
    }


}

