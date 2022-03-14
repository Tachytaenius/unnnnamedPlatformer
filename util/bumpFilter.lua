local registry = require("registry")

local getTileTypeFromIndex = require("util.getTileTypeFromIndex")

return function(item, other)
	local world = item.world
	if type(other) == "number" then
		other = getTileTypeFromIndex(other, "mainTiles", world)
		if other.solid then
			return "slide"
		end
		return false
	else -- entity
		if not other.nonSolid then
			return "slide"
		end
	end
end
