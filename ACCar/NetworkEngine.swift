//
//  NetworkEngine.swift
//  ACCar
//
//  Created by Andrew Cavanagh on 3/12/15.
//  Copyright (c) 2015 WeddingWire. All rights reserved.
//

import Foundation

private let kAddress = "192.168.5.1:3000"
private let _sharedInstance = NetworkEngine()

class NetworkEngine {
    
    private var opQueue = NSOperationQueue()
    
    class var sharedInstance: NetworkEngine {
        return _sharedInstance
    }
    
    func transmitData(data: NSData) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: kAddress)!)
        
        //NSURLConnection.sendAsynchronousRequest(request, queue: <#NSOperationQueue!#>, completionHandler: <#(NSURLResponse!, NSData!, NSError!) -> Void##(NSURLResponse!, NSData!, NSError!) -> Void#>)
        
    }
    
}