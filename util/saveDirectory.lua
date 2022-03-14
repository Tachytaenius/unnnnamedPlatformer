-- Ensure proper separation of program and save data directories

local consts = require("consts")

local saveDirectory = {}

function saveDirectory:enable()
	love.filesystem.setIdentity(consts.identity, false)
end

function saveDirectory:disable()
	love.filesystem.setIdentity("")
end

return saveDirectory
