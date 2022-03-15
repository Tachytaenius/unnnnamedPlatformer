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
	elseif other.border then -- border
		return "slide"
	else -- entity
		local otherEntityType = registry.entityTypes[other.type]
		if not otherEntityType.nonSolid then
			return "slide"
		else
			return "cross"
		end
	end
end
