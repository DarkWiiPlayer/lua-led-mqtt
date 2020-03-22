local name = require 'name'

return {
	name = name;
	broker = { ip = '10.0.0.2', port = 1883 };
	topics = { "led", "led/"..name };
	ledcount = 5;
}
