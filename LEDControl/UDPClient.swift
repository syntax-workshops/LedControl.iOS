//
//  UDPClient.swift
//  LEDControl
//
//  Created by Mathijs Bernson on 06/01/16.
//  Copyright © 2016 Duckson. All rights reserved.
//

import Foundation

func htons(value: CUnsignedShort) -> CUnsignedShort {
  return (value << 8) + (value >> 8);
}

class UDPClient {

  let port: CUnsignedShort
  let ip: String

  let INADDR_ANY = in_addr(s_addr: 0)

  let fd = socket(AF_INET, SOCK_DGRAM, 0) // DGRAM makes it UDP
  var addr: sockaddr_in

  init(ip: String, port: CUnsignedShort) {
    self.port = port
    self.ip = ip
    self.addr = sockaddr_in(
      sin_len:    __uint8_t(sizeof(sockaddr_in)),
      sin_family: sa_family_t(AF_INET),
      sin_port:   htons(port),
      sin_addr:   INADDR_ANY,
      sin_zero:   ( 0, 0, 0, 0, 0, 0, 0, 0 )
    )
    ip.withCString { cstr -> Void in
      self.addr.sin_addr.s_addr = inet_addr(cstr)
    }
  }

  func send(message: [UInt8]) {
    withUnsafePointer(&addr) { ptr -> Void in
      let addrptr = UnsafePointer<sockaddr>(ptr)
      sendto(fd, message, message.count, 0, addrptr, socklen_t(addr.sin_len))
    }
  }

  func send(message: String) {
    message.withCString { cstr -> Void in
      withUnsafePointer(&addr) { ptr -> Void in
        let addrptr = UnsafePointer<sockaddr>(ptr)
        sendto(fd, cstr, Int(strlen(cstr)), 0,
          addrptr, socklen_t(addr.sin_len))
      }
    }
  }
}