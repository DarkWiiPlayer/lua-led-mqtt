gpio.mode(0, gpio.INPUT, gpio.PULLUP)

if gpio.read(0) == gpio.HIGH then
	print(pcall(function()
		local config = require 'config'
		require 'enable-wifi' (config.name, require 'listener')
	end))
else
	print("Pin 0 is grounded: entering debug mode")
end
