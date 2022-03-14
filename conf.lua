local consts = require("consts")

function love.conf(t)
	-- t.identity is not set like this because this program tries to avoid the save-and-program-directory-merging behaviour of LÖVE
	t.window.width = consts.contentWidth * consts.contentScale
	t.window.height = consts.contentHeight * consts.contentScale
end
