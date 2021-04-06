local json = require 'sjson'
local config = require 'config'

local darkled = require 'darkled'

return function(num_leds)
	local client = require('mqtt').Client(config.name, 10)

	print("Connecting to MQTT broker on "..config.broker.ip.."...")
	client:connect(config.broker.ip, config.broker.port, false, function(client)
		print("Connected to MQTT broker on "..config.broker.ip.."!")
		client:publish('nodemcu/led/status', json.encode{name=config.name, status="online", message=config.messages.status.online}, 0, 0)
		client:lwt('nodemcu/led/status', json.encode{name=config.name, status="online", message=config.messages.status.online}, 0, 0)

		for _, topic in ipairs(config.topics) do
			client:subscribe(topic, 0)
		end

		client:on('message', function(client, topic, message)
			local data = assert(json.decode(message))
			if data.protocol == 'darkled' then
				darkled(data)
			end
			collectgarbage()
		end)
	end, function(client, reason)
		print("Could not connect: ", reason)
	end)
end
