//
//  LedStrip.swift
//  LEDControl
//
//  Created by Mathijs Bernson on 17/03/16.
//  Copyright © 2016 Duckson. All rights reserved.
//

import Foundation

class LEDStrip {
  var ledcount: Int

  var ip: String
  let port: CUnsignedShort = 80

  var udpClient: UDPClient

  var color: UIColor = UIColor.whiteColor()
  var brightness: CGFloat = 1.0

  convenience init(userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
    self.init(ipAddress: userDefaults.stringForKey("ledStripIpAddress")!, count: userDefaults.integerForKey("ledStripCount"))
  }

  init(ipAddress: String, count: Int) {
    ledcount = count
    ip = ipAddress

    udpClient = UDPClient(ip: ip, port: port)
  }

  func reload() {
    udpClient = UDPClient(ip: ip, port: port)
  }

  func send(message: [UInt8]) {
    udpClient.send(message)
  }

  func clear() {
    let message = [UInt8](count: ledcount * 3, repeatedValue: 0)
    udpClient.send(message)
  }
}