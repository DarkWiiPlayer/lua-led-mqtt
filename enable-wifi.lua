local config = require 'config'

return function(name, connected)
	 function config.wifi.got_ip_cb(options)
		if connected then connected() end
	end;

	wifi.setmode(wifi.STATION, true)
	wifi.sta.config(config.wifi)
	wifi.sta.sethostname(name)
end
