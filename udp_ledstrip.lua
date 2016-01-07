-- The control pin for your LED strip
pin = 4

-- Amount of LED pixels on the strip
pixels = 75

-- WiFi config
ssid = "Your wifi network"
psk = "Your wifi password"

-- UDP port to receive data on
port = 80

-- That's all, you don't have to edit anything else!

wifi.setmode(wifi.STATION)
wifi.sta.config(ssid, psk)
print(wifi.sta.getip())

-- Turn all LEDs off
ws2812.write(pin, string.char( 0,  0,  0):rep(pixels))

if srv then
    srv:close()
    srv = nil
end

srv = net.createServer(net.UDP)

srv:on("receive", function(client, data)
    ws2812.write(pin, data)
end)
srv:listen(port)
