local registry = require("registry")

return function(i, layerTable, world)
	local x = i % world.tileMapWidth
	local y = math.floor(i / world.tileMapWidth)
	return registry.tileTypes[world[layerTable][x][y]]
end
