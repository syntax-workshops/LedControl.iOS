//
//  ViewController.swift
//  LEDControl
//
//  Created by Mathijs Bernson on 06/01/16.
//  Copyright © 2016 Duckson. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ISColorWheelDelegate {
    
    class LEDStrip {
        let ledcount: Int
        
        var ip: String
        let port: CUnsignedShort = 80
        
        var udpClient: UDPClient
        
        var color: UIColor = UIColor.whiteColor()
        var brightness: CGFloat = 1.0
        
        init(count: Int) {
            ledcount = count
            ip = NSUserDefaults.standardUserDefaults().stringForKey("ledStripIpAddress")!
            
            udpClient = UDPClient(ip: ip, port: port)
        }
        
        func reload() {
            udpClient = UDPClient(ip: ip, port: port)
        }
        
        func send(message: [UInt8]) {
            udpClient.send(message)
        }
    }

    var strip: LEDStrip = LEDStrip(count: 83)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ipAddress.text = strip.ip
        
        // Set up color wheel
        let size = self.view.bounds.size
        let wheelSize = CGSizeMake(size.width * 0.9, size.width * 0.9);
        
        let colorWheel = ISColorWheel.init(frame: CGRectMake(
            size.width / 2 - wheelSize.width / 2 - 16, // Yay, ugly UI code
            size.height * 0.1,
            wheelSize.width,
            wheelSize.height
        ))
        colorWheel.delegate = self
        colorWheel.borderWidth = 1
        self.colorWheelView.addSubview(colorWheel)
        colorWheel.continuous = true
    }

    @IBOutlet weak var colorWheelView: UIView!
    @IBOutlet weak var ipAddress: UITextField!
    
    var brightnessChange: CGFloat = 0
    
    @IBAction func brightnessSliderChanged(sender: UISlider) {
        ipAddress.resignFirstResponder()
        
        let oldBrightness = strip.brightness
        let newBrightness = CGFloat(sender.value)
        let threshold: CGFloat = 0.05
        strip.brightness = newBrightness
        brightnessChange += abs(oldBrightness - newBrightness)
        
        if brightnessChange >= threshold {
            brightnessChange = 0
            sendMessage()
        }
    }
    
    @IBAction func ipAddressChanged(sender: AnyObject) {
        updateIpAddress()
    }
    
    @IBAction func viewWasTapped(sender: AnyObject) {
        ipAddress.resignFirstResponder()
    }
    
    private func updateIpAddress() {
        if ipAddress.text != "" && ipAddress.text != nil {
            strip.ip = ipAddress.text!
            NSUserDefaults.standardUserDefaults().setValue(strip.ip, forKey: "ledStripIpAddress")
        }
        strip.reload()
    }
    
    func sendMessage() {
        let message = composeMessageFromColor(color: strip.color, ledcount: strip.ledcount, brightness: strip.brightness)
        strip.send(message)
    }
    
    private func composeMessageFromColor(color color: UIColor, ledcount: Int, brightness: CGFloat) -> [UInt8] {
        var message = [UInt8]()
        
        let rgb = color.rgb()
        for _ in 0...ledcount {
            let r = rgb.0,
                g = rgb.1,
                b = rgb.2
            
            message.append(UInt8(g * brightness))
            message.append(UInt8(r * brightness))
            message.append(UInt8(b * brightness))
        }
        
        return message
    }

    func colorWheelDidChangeColor(colorWheel: ISColorWheel) {
        ipAddress.resignFirstResponder()
        strip.color = colorWheel.currentColor
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
            
            return (iRed, iGreen, iBlue)
        } else {
            // Could not extract RGBA components:
            return (0, 0, 0)
        }
    }
}
