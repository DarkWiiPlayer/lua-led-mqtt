local ws2812 = require 'ws2812'
ws2812.init()

local config = require 'config'
local Timer = require 'timer'

local timer = Timer.new()
local buffer = ws2812.newBuffer(config.ledcount, 3)

local function switch_rg(tab) tab[1], tab[2] = tab[2], tab[1]; return tab end

ws2812.write(buffer)

local function interpolate(from, to, value, max)
	if max then value = value/max end
	return
		math.floor(from[1] + (to[1]-from[1])*value),
		math.floor(from[2] + (to[2]-from[2])*value),
		math.floor(from[3] + (to[3]-from[3])*value)
end

local commands = {}

function commands.fill(data)
	timer:stop()
	buffer:fill(unpack(switch_rg(data.color)))
	ws2812.write(buffer)
end

function commands.fade(data)
	local t = 50e-3
	timer:set(t*1e3, function()
		local time = data.time * 1/t
		local from = switch_rg(data.from)
		local to = switch_rg(data.to)

		for i=1,time do
			buffer:fill(interpolate(from, to, i, time))
			ws2812.write(buffer)
			coroutine.yield()
		end
	end)
end;

function commands.wave(data)
	local wait_next_frame = coroutine.yield
	local t = 50e-3
	local low = switch_rg(data.low)
	local high = switch_rg(data.high)
	local tmin, tdmax = data.min, data.max
	timer:set(t*1e3, function()
		while true do
			local time = (tmin+math.random()*tdmax) / t
			for i=1,time do
				buffer:fill(interpolate(high, low, i, time))
				ws2812.write(buffer)
				wait_next_frame()
			end
			high, low = low, high
		end
	end)
end

function commands.rainbow(data)
	local color = require 'color_utils'
	local inv_steps = 1 / 360
	local t = data.duration * inv_steps
	local angle = 0
	timer:set(t*1e3, function()
		while true do
			angle = (angle + 1) % 360
			buffer:fill(color.colorWheel(math.floor(angle)))
			ws2812.write(buffer)
			coroutine.yield()
		end
	end)
end

return function(data)
	if config.path and data.path and config.path:find(data.path)~=1 then
		return true, "Wrong device path, skipping"
	end
	if commands[data.command] then
		return commands[data.command](data)
	else
		print("Unknown command: "..data.commands)
	end
end
