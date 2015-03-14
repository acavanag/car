//
//  ViewController.swift
//  ACCar
//
//  Created by Andrew Cavanagh on 3/12/15.
//  Copyright (c) 2015 WeddingWire. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CameraEngineDelegate {

    var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(imageView)
        imageView.contentMode = .ScaleAspectFit
        NetworkEngine.sharedInstance.openConnection()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        imageView.frame = self.view.bounds
        CameraEngine.sharedInstance().delegate = self
        CameraEngine.sharedInstance().start()
    }

    func didCaptureFrame(pixelBrightness: NSData!, image: UIImage!) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NetworkEngine.sharedInstance.transmitFrame(pixelBrightness)
            self.imageView.image = image
        })
    }
}

