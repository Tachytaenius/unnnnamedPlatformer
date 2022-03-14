local registry = require("registry")

return function(entity)
	return entity.position.x, entity.position.y, registry.entityTypes[entity.type].width, registry.entityTypes[entity.type].height
end
