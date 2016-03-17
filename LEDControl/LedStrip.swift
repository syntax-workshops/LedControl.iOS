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

  init(count: Int) {
    ledcount = count
    ip = NSUserDefaults.standardUserDefaults().stringForKey("ledStripIpAddress") ?? "192.168.1.42"

    udpClient = UDPClient(ip: ip, port: port)
  }

  func reload() {
    udpClient = UDPClient(ip: ip, port: port)
  }

  func send(message: [UInt8]) {
    udpClient.send(message)
  }
}