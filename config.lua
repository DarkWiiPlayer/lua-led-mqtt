local json = require 'sjson'

local f = assert(file.open("config.json"))
local config = f:read(1024*8)
f:close()

config = json.decode(config)

return config
