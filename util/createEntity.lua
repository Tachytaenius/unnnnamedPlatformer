local vec2 = require("lib.mathsies").vec2

local registry = require("registry")

local getXYWH = require("util.getXYWH")

local function createEntity(world, descriptor)
	local newEntity = {}
	local entityType = registry.entityTypes[descriptor.type]
	assert(entityType, "Entity type \"" .. descriptor.type .. "\" not defined")
	newEntity.type = descriptor.type
	newEntity.position = vec2(descriptor.position[1], descriptor.position[2])
	newEntity.velocity = vec2()
	newEntity.world = world
	newEntity.direction = descriptor.direction == "right" and 1 or descriptor.direction == "left" and -1 or descriptor.direction or 1
	newEntity.onGround = false
	newEntity.jumpTimeLeft = 0
	if entityType.hasWalkCycle then
		newEntity.walkCycleTimer = 0
	end
	if entityType.picksUp then
		newEntity.inventory = {}
	end
	newEntity.health = entityType.maxHealth
	world.bumpWorld:add(newEntity, getXYWH(newEntity))
	return newEntity
end

return createEntity
