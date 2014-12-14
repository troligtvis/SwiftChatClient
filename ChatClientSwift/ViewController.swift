//
//  ViewController.swift
//  ChatClientSwift
//
//  Created by Kj Drougge on 2014-12-12.
//  Copyright (c) 2014 kj. All rights reserved.
//

import UIKit


class ViewController: UIViewController, NSStreamDelegate {

    private let serverAddress: CFString = "127.0.0.1"
    private let serverPort: UInt32 = 3490

    private var inputStream: NSInputStream!
    private var outputStream: NSOutputStream!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initNetworkCommunication()
    }
    
    @IBAction func sendBtn(sender: AnyObject) {
        sendData()
    }
    @IBOutlet weak var textField: UITextField!

    func initNetworkCommunication(){
        
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, self.serverAddress, self.serverPort, &readStream, &writeStream)
        
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        self.inputStream.delegate = self
        self.outputStream.delegate = self
        
        self.inputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        self.outputStream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        self.inputStream.open()
        self.outputStream.open()
    }

    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        switch eventCode{
        case NSStreamEvent.OpenCompleted:
            println("Stream opened")
            break
        case NSStreamEvent.HasSpaceAvailable:
            if outputStream == aStream{
                println("outputstream is ready!")
            }
            break
        case NSStreamEvent.HasBytesAvailable:
            println("has bytes")
             if aStream == inputStream{
                var buffer: UInt8 = 0
                var len: Int!
               
                while (inputStream?.hasBytesAvailable != nil){
                    len = inputStream?.read(&buffer, maxLength: 1024)
                    if len > 0{
                        var output = NSString(bytes: &buffer, length: len, encoding: NSASCIIStringEncoding)
            
                        if nil != output{
                            println("Server said: \(output)")
                            output = output?.substringFromIndex(11)
                        }
                    }
                }
            }
            break
        case NSStreamEvent.ErrorOccurred:
            println("Can not connect to the host!")
            break
        case NSStreamEvent.EndEncountered:
            outputStream.close()
            outputStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            outputStream = nil
            break
        default:
                println("Unknown event")
        }
    }
    
    func sendData(){
        var response = "\(textField.text)\r\n"
            if textField.text != "" {
            var data = NSData(data: response.dataUsingEncoding(NSASCIIStringEncoding)!)
            //println("response: \(response) data.length: \(data.length)")
        
            outputStream?.write(UnsafePointer<UInt8>(data.bytes) , maxLength: data.length)
        
            textField.text = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}