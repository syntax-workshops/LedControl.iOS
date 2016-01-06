//
//  ViewController.swift
//  LEDControl
//
//  Created by Mathijs Bernson on 06/01/16.
//  Copyright © 2016 Duckson. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ISColorWheelDelegate {

    var sending: Bool = false
    var ip: String = "192.168.1.221"
    let ledcount = 83
    var udpClient = UDPClient(ip: "192.168.1.221", port: 80)
    
    var color: UIColor = UIColor.whiteColor()
    var brightness: CGFloat = 0.5
    
    var timer: NSTimer?
    let interval: NSTimeInterval = 0.5
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var colorWheelView: UIView!
    @IBOutlet weak var ipAddress: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func brightnessSliderChanged(sender: UISlider) {
        brightness = CGFloat(sender.value)
        print("Brightness: \(brightness)")
    }
    
    @IBAction func sendButtonPressed(sender: UIButton) {
        if ipAddress.text != "" && ipAddress.text != nil {
            ip = ipAddress.text!
        }
        
        if sending {
            stopSending()
        } else {
            startSending()
        }
    }
    
    func startSending() {
        sending = true
        
        sendButton.setTitle("Stop met zenden", forState: .Normal)
        activityIndicator.startAnimating()
        
        createTimer()
        timer?.fire()
    }
    
    func stopSending() {
        sending = false
        sendButton.setTitle("Start met zenden", forState: .Normal)
        activityIndicator.stopAnimating()
        timer?.invalidate()
    }
    
    func createTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "sendMessage",
            userInfo: nil, repeats: true)
    }
    
    func sendMessage() {
        if sending {
            print("Sending message")
            let message = composeMessageFromColor()
            udpClient.send(message)
        }
    }
    
    func composeMessageFromColor() -> [UInt8] {
        var message = [UInt8]()
        
        let rgb = color.rgb()
        for _ in 0...ledcount {
            let r = rgb.0,
                g = rgb.1,
                b = rgb.2
            
            message.append(UInt8(g*brightness))
            message.append(UInt8(r*brightness))
            message.append(UInt8(b*brightness))
        }
        
        return message
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ipAddress.text = ip

        let size = self.view.bounds.size
        
        let wheelSize = CGSizeMake(size.width * 0.9, size.width * 0.9);
        
        let colorWheel = ISColorWheel.init(frame: CGRectMake(size.width / 2 - wheelSize.width / 2 - 16,
            size.height * 0.1,
            wheelSize.width,
            wheelSize.height))
        colorWheel.delegate = self
        colorWheel.borderWidth = 0.5
        self.colorWheelView.addSubview(colorWheel)
        colorWheel.continuous = true
        
        startSending()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func colorWheelDidChangeColor(colorWheel: ISColorWheel) {
        color = colorWheel.currentColor
        sendMessage()
    }
}

extension UIColor {
    
    func rgb() -> (CGFloat, CGFloat, CGFloat) {
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = CGFloat(fRed * 255.0)
            let iGreen = CGFloat(fGreen * 255.0)
            let iBlue = CGFloat(fBlue * 255.0)
//            let iAlpha = Int(fAlpha * 255.0)
            
            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
//            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return (iRed, iGreen, iBlue)
        } else {
            // Could not extract RGBA components:
            return (0, 0, 0)
        }
    }
}
