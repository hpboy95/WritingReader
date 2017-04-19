//
//  CameraViewController.swift
//  WritingReader
//
//  Created by Guillermo Colin on 4/19/17.
//  Copyright © 2017 Hezekiah Valdez. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        
        //captureSession.sessionPreset = AVCaptureSessionPresetLow
        let devices = AVCaptureDevice.devices()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
