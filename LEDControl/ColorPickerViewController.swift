//
//  ColorPickerViewController.swift
//  LEDControl
//
//  Created by Mathijs Bernson on 06/01/16.
//  Copyright © 2016 Duckson. All rights reserved.
//

import UIKit

func frameForColorWheel(inView view: UIView) -> CGRect {
  let size = view.bounds.size
  let wheelSize = CGSizeMake(size.width * 0.9, size.width * 0.9);

  return CGRect(
    x: size.width / 2 - wheelSize.width / 2 - 16, // Yay, ugly UI code
    y: size.height * 0.1,
    width: wheelSize.width,
    height: wheelSize.height
  )
}

class ColorPickerViewController: UIViewController {

  var strip: LEDStrip!
  var colorWheel: ISColorWheel!
  var brightnessChange: CGFloat = 0

  override func viewDidLoad() {
    super.viewDidLoad()

    strip = LEDStrip()

    ipAddress.text = strip.ip
    countTextField.text = String(strip.ledcount)

    // Set up color wheel
    colorWheel = ISColorWheel(frame: frameForColorWheel(inView: view))
    colorWheel.delegate = self
    colorWheel.borderWidth = 1
    self.colorWheelView.addSubview(colorWheel)
    colorWheel.continuous = true
  }

  // MARK: Outlets

  @IBOutlet weak var countTextField: UITextField!
  @IBOutlet weak var colorWheelView: UIView!
  @IBOutlet weak var ipAddress: UITextField!

  @IBAction func brightnessSliderChanged(sender: UISlider) {
    ipAddress.resignFirstResponder()

    let oldBrightness = strip.brightness
    let newBrightness = CGFloat(sender.value)
    let threshold: CGFloat = 0.05
    strip.brightness = newBrightness
    brightnessChange += abs(oldBrightness - newBrightness)

    if brightnessChange >= threshold {
      brightnessChange = 0
      colorWheel.brightness = newBrightness
      sendMessage()
    }
  }

  // MARK: Actions

  @IBAction func ipAddressChanged(sender: AnyObject) {
    guard let newAddress = ipAddress.text else { return }

    strip.ip = newAddress
    NSUserDefaults.standardUserDefaults().setValue(newAddress, forKey: "ledStripIpAddress")

    strip.reload()
  }

  @IBAction func countChanged(sender: AnyObject) {
    guard let text = countTextField.text, count = Int(text) where count >= 0 else { return }

    strip.ledcount = count
    NSUserDefaults.standardUserDefaults().setValue(countTextField.text, forKey: "ledStripCount")
  }

  @IBAction func clearStripButtonPressed(sender: AnyObject) {
    strip.clear()
  }

  @IBAction func viewWasTapped(sender: AnyObject) {
    hideKeyboard()
  }

  // MARK: Logic

  private func hideKeyboard() {
    ipAddress.resignFirstResponder()
    countTextField.resignFirstResponder()
    sendMessage()
  }

  private func sendMessage() {
    let message = composeMessageFromColor(color: strip.color, ledcount: strip.ledcount, brightness: strip.brightness)
    strip.send(message)
  }

  private func composeMessageFromColor(color color: UIColor, ledcount: Int, brightness: CGFloat) -> [UInt8] {
    var message = [UInt8]()

    let rgb = color.rgb()
    for _ in 1...ledcount {
      let r = rgb.0,
      g = rgb.1,
      b = rgb.2

      message.append(UInt8(g * brightness))
      message.append(UInt8(r * brightness))
      message.append(UInt8(b * brightness))
    }

    return message
  }
}

extension ColorPickerViewController: ISColorWheelDelegate {
  func colorWheelDidChangeColor(colorWheel: ISColorWheel) {
    ipAddress.resignFirstResponder()
    strip.color = colorWheel.currentColor
    sendMessage()
  }
}

extension ColorPickerViewController: UITextFieldDelegate {
  func textFieldDidEndEditing(textField: UITextField) {
    hideKeyboard()
  }

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if let text = textField.text where !text.isEmpty {
      return true
    }
    return false
  }
}