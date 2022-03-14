local json = require("lib.json")
local list = require("lib.list")
local vec2 = require("lib.mathsies").vec2
local bump = require("lib.bump")

local consts = require("consts")
local registry = require("registry")

local csvToBin = require("util.csvToBin")
local createEntity = require("util.createEntity")

local function loadMap(path)
	path = "assets/levels/" .. path .. "/"
	local world, player, camera
	world = {}
	world.bumpWorld = bump.newWorld()
	
	-- info.json
	local infoJson = json.decode(love.filesystem.read(path .. "info.json"))
	world.gravity = infoJson.gravity and vec2(infoJson.gravity[1], infoJson.gravity[2]) or consts.defaultGravity
	world.tileMapWidth = infoJson.tileMapWidth
	world.tileMapHeight = infoJson.tileMapHeight
	
	-- entities.json
	local entitiesJson = json.decode(love.filesystem.read(path .. "entities.json"))
	world.entities = list()
	for _, entityDescriptor in ipairs(entitiesJson) do
		local entity = createEntity(world, entityDescriptor)
		if entityDescriptor.player then
			-- extendable for multiplayer
			player = entity
		end
		if entityDescriptor.camera then
			camera = entity
		end
		world.entities:add(entity)
	end
	
	-- tileIds.txt
	local tileNamesById = {}
	local i = 0
	for name in love.filesystem.lines(path .. "tileIds.txt") do
		tileNamesById[i] = name
		assert(registry.tileTypes[name])
		i = i + 1
	end
	
	-- background/main/foregroundTileData.bin (or csv)
	local function loadTileData(name, layerTable, colliders)
		world[layerTable] = {}
		local tileDataString = love.filesystem.read(path .. name .. "TileData.bin")
		if not tileDataString then
			tileDataString = csvToBin(love.filesystem.read(path .. name .. "TileData.csv"))
		end
		for x = 0, world.tileMapWidth - 1 do
			world[layerTable][x] = {}
			for y = 0, world.tileMapHeight - 1 do
				local i = x + world.tileMapWidth * y
				local tile = tileNamesById[tileDataString:sub(i+1, i+1):byte()]
				world[layerTable][x][y] = tile
				if colliders then
					world.bumpWorld:add(i, x * consts.tileSize, y * consts.tileSize, consts.tileSize, consts.tileSize)
				end
			end
		end
	end
	loadTileData("background", "backgroundTiles", false)
	loadTileData("main", "mainTiles", true)
	-- loadTileData("background", "foregroundTiles", false)
	
	-- Add borders
	local w, h = world.tileMapWidth * consts.tileSize, world.tileMapHeight * consts.tileSize
	world.bumpWorld:add({border = "leftBorder", solid = true}, -1, -1, 1, h + 1 + consts.pitDeathDepth)
	world.bumpWorld:add({border = "rightBorder", solid = true}, w, -1, 1, h + 1 + consts.pitDeathDepth)
	world.bumpWorld:add({border = "topBorder", solid = true}, -1, -1, w + 2, 1)
	
	return world, player, camera
end

return loadMap
