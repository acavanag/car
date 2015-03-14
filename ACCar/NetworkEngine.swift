//
//  NetworkEngine.swift
//  ACCar
//
//  Created by Andrew Cavanagh on 3/12/15.
//  Copyright (c) 2015 WeddingWire. All rights reserved.
//

import Foundation

private let kAddress = "ws://192.168.5.140:8080"
private let _sharedInstance = NetworkEngine()

class NetworkEngine : NSObject, SRWebSocketDelegate {
    
    private var socket: SRWebSocket!
    private var socketIsOpen: Bool = false
    
    private var sent: Int = 0
    
    class var sharedInstance: NetworkEngine {
        return _sharedInstance
    }
    
    private override init() {}
    
    func openConnection() {
        socket = SRWebSocket(URL: NSURL(string: kAddress)!)
        socket.delegate = self
        socket.open()
    }
    
    func closeConnection() {
        socketIsOpen = false
        socket.close()
        socket = nil
    }
    
    func transmitFrame(data: NSData) {
        if socket != nil && socketIsOpen == true {
            socket.send(data)
            println("sent: \(++sent)")
        }
    }
    
    internal func webSocketDidOpen(webSocket: SRWebSocket!) {
        println(__FUNCTION__)
        socketIsOpen = true
        socket.send("0")
    }
    
    internal func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        println(__FUNCTION__)
    }
    
    internal func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        println(error)
    }
    
    internal func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        println(message)
    }
    
}