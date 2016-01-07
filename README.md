# LED control

This is a simple app for controlling the color and brightness of my **ws2812b** RGB LED strip, based on the esp8266 (NodeMCU) platform.

It lets the user select a color and brightness level, which are automatically sent over the local network to the LED strip.
The LED strip maintains the last color/brightness values it received until the user restarts it.

## Technical

The app works by sending R, G and B bytes for each LED over UDP. For example, if we have a strip of 75 RGB LEDs, the control sequence will be 75 * 3 bytes:

```
[255, 255, 255, ... /* repeated 74 more times */]
```

**Note**: For some weird reason, NodeMCU expects `(g, r, b)` tuples instead of `(r, g, b)`.

## Installation

* Install [NodeMCU firmware](https://github.com/nodemcu/nodemcu-firmware/) on your esp8266 module.
* Edit the file `udp_ledstrip.lua`, copy it over, and configure it to run automatically.
* Install the app and configure the IP address.

## Acknowledgements

This project makes use of the [ios-color-wheel](https://github.com/justinmeiners/ios-color-wheel) library by Justin Meiners, which is MIT licensed.

The app icon is based on: [LED by Dmitry Mirolyubov from the Noun Project](https://thenounproject.com/search/?q=led&i=120701).

## License

MIT, see `LICENSE.txt`