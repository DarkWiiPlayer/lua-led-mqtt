local setup_pin = 1
local ledpin = 2

gpio.mode(ledpin, gpio.OUTPUT)
gpio.write(ledpin, gpio.LOW)

gpio.mode(setup_pin, gpio.INPUT, gpio.PULLUP)
gpio.trig(1, "down", function()
	node.restart()
end)

local function handler(message)
	print(debug.traceback(message))
end

if gpio.read(setup_pin) == gpio.HIGH then
	xpcall(function()
		local config = require 'config'
		require 'enable-wifi' (config.name, require 'listener')
	end, handler)
else
	xpcall(function()
		require('setup')()
	end, handler)
end
