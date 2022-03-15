local json = require("lib.json")

local registry = {
	entityTypes = {},
	tileTypes = {}, numTileTypes = 0
}

local function traverse(registryTable, path, createFromJson, registryPathPrefixLength)
	registryPathPrefixLength = registryPathPrefixLength or path
	for _, itemName in ipairs(love.filesystem.getDirectoryItems(path)) do
		local path = path .. itemName
		if love.filesystem.getInfo(path, "directory") then
			traverse(registryTable, path .. "/", createFromJson, registryPathPrefixLength)
		elseif love.filesystem.getInfo(path, "file") then
			if itemName:match("%.json$") then
				local entryName = itemName:sub(1, -6) -- remove .json
				local jsonData = json.decode(love.filesystem.read(path))
				local entry = createFromJson(jsonData, path)
				entry.assetPath = path:sub(#registryPathPrefixLength + 1, -6) -- remove registryPathPrefixLength and .json
				entry.name = entryName
				registryTable[entryName] = entry
			end
		end
	end
end

local function createEntityType(jsonData, path)
	local newEntityType = {}
	newEntityType.width = jsonData.width
	newEntityType.height = jsonData.height
	newEntityType.jumpSpeed = jsonData.jumpSpeed
	newEntityType.maxWalkSpeed = jsonData.maxWalkSpeed
	newEntityType.maxFallSpeed = jsonData.maxFallSpeed
	newEntityType.acceleration = jsonData.acceleration
	newEntityType.deceleration = jsonData.deceleration
	newEntityType.airAcceleration = jsonData.airAcceleration
	newEntityType.walkCycleTime = jsonData.walkCycleTime
	newEntityType.dontChangeDirectionInAir = jsonData.dontChangeDirectionInAir
	newEntityType.fallPoseSpeed = jsonData.fallPoseSpeed or 0
	newEntityType.skidSpeed = jsonData.skidSpeed or 0
	newEntityType.skidWhenTryingToStop = jsonData.skidWhenTryingToStop
	newEntityType.hasWalkCycle = not not jsonData.walkCycleTime
	newEntityType.maxHealth = jsonData.maxHealth or 1
	newEntityType.maxJumptime = jsonData.maxJumptime or 0
	newEntityType.jumpGravityMultiplier = jsonData.jumpGravityMultiplier or 1 -- jump time has no effect with gravity multiplier 1
	newEntityType.noGravity = jsonData.noGravity
	newEntityType.pickUp = jsonData.pickUp -- table, what to give when picked up
	newEntityType.picksUp = jsonData.picksUp -- bool, can this entity pick up things with pickUp
	newEntityType.nonSolid = jsonData.nonSolid
	newEntityType.dontChangeDirectionWhileSkidding = jsonData.dontChangeDirectionWhileSkidding
	return newEntityType
end

local function createTileType(jsonData, path)
	local newTileType = {}
	newTileType.solid = jsonData.solid
	newTileType.animationLength = jsonData.animationLength
	newTileType.animated = not not jsonData.animationLength
	newTileType.kills = jsonData.kills
	newTileType.friction = jsonData.friction
	registry.numTileTypes = registry.numTileTypes + 1
	return newTileType
end

traverse(registry.entityTypes, "registry/entities/", createEntityType)
traverse(registry.tileTypes, "registry/tiles/", createTileType)

return registry
