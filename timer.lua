--- A neat abstraction around timers that uses coroutines.

local tmr = require 'tmr'

local timer = {}
timer.__index = timer

--- Creates a new timer from a given function.
function timer.new()
	local new = setmetatable({timer=tmr.create()}, timer)
	new.__index = new
	return new
end

function timer:stop()
	self.timer:unregister()
end

function timer:set(time, fn, done)
	local t = self.timer
	self:stop()
	local co = coroutine.create(fn)
	t:register(math.floor(time), tmr.ALARM_AUTO, function()
		if coroutine.status(co) == 'suspended' then
			local ok, message = coroutine.resume(co)
			if not ok then
				print("Error in timer: "..message)
			end
		end
		if coroutine.status(co) == 'dead' then
			t:unregister()
			if type(done)=='function' then done() end
		end
	end)
	t:start()
end

return timer
