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
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        imageView.frame = self.view.bounds
        CameraEngine.sharedInstance().delegate = self
        CameraEngine.sharedInstance().start()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didCaptureFrame(pixelBrightness: NSData!, image: UIImage!) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            println(pixelBrightness.length)
            self.imageView.image = image
        })
    }
}

