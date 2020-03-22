print(pcall(function()
	local config = require 'config'
	require 'enable-wifi' (config.name, require 'listener')
end))
