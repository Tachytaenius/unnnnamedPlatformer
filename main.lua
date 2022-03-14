require("monkeypatch")

local list = require("lib.list")
local vec2 = require("lib.mathsies").vec2
local bump = require("lib.bump")
local quadreasonable = require("lib.quadreasonable")

local consts = require("consts")
local registry = require("registry")
local assets = require("assets")

local csvToBin = require("util.csvToBin")
local saveDirectory = require("util.saveDirectory")
local animatedTiles = require("util.animatedTiles")
local loadMap = require("util.loadMap")
local getXYWH = require("util.getXYWH")
local bumpFilter = require("util.bumpFilter")
local getTileTypeFromIndex = require("util.getTileTypeFromIndex")

local world, player, camera, paused
local contentCanvas
local keyPressed, keyReleased

function love.load(arg)
	if arg[1] == "csvToBin" then
		saveDirectory:enable()
		local csv = love.filesystem.read(arg[2])
		love.filesystem.write(arg[2]:sub(1, -5)..".bin", csvToBin(csv))
		saveDirectory:disable()
		love.event.quit()
		return
	end
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.graphics.setLineStyle("rough")
	assets.load()
	animatedTiles:reset()
	world, player, camera = loadMap("testScene")
	paused = false
	contentCanvas = love.graphics.newCanvas(consts.contentWidth, consts.contentHeight)
	keyPressed, keyReleased = {}, {}
end

local function limitMagnitude(x, max)
	local sx = math.sign(x)
	local ax = math.abs(x)
	return sx * math.min(max, ax)
end

function love.keypressed(key) keyPressed[key] = true end
function love.keyreleased(key) keyReleased[key] = true end
function love.update(dt)
	for entity in world.entities:elements() do
		local entityType = registry.entityTypes[entity.type]
		local prevPosX = entity.position.x
		local move = 0
		local dontResetWalkTimer
		if entity == player then
			if love.keyboard.isDown("a") then
				move = move - 1
			end
			if love.keyboard.isDown("d") then
				move = move + 1
			end
			if not (not entity.onGround and entityType.dontChangeDirectionInAir) then
				if math.sign(move) == -1 then
					entity.direction = -1
				elseif math.sign(move) == 1 then
					entity.direction = 1
				end
			end
			local accel = 0
			if entity.onGround then
				local increase = move ~= 0 and (math.sign(move) == math.sign(entity.velocity.x) or entity.velocity.x == 0)
				accel = increase and entityType.acceleration or entityType.deceleration
				if increase then
					entity.velocity.x = entity.velocity.x + move * accel * dt
				else
					local xSpeedSign = math.sign(entity.velocity.x)
					local xSpeedMagnitude = math.abs(entity.velocity.x)
					local wasNonZero = entity.velocity.x ~= 0
					xSpeedMagnitude = math.max(0, xSpeedMagnitude - accel * dt)
					entity.velocity.x = xSpeedSign * xSpeedMagnitude
					if entity.velocity.x == 0 and not wasNonZero then
						dontResetWalkTimer = true
					end
				end
			else
				entity.velocity.x = entity.velocity.x + move * entityType.airAcceleration * dt
			end
			if entity.onGround and keyPressed.space then
				entity.jumpTimeLeft = entityType.maxJumptime
				entity.velocity.y = entity.velocity.y - entityType.jumpSpeed
			end
		end
		entity.onGround = false
		local collidedX = false
		local newPosition = entity.position + entity.velocity * dt
		entity.position.x, entity.position.y, cols, len = world.bumpWorld:move(entity, newPosition.x, newPosition.y, bumpFilter)
		local friction = 0
		for _, col in ipairs(cols) do
			if type(col.other) == "number" then
				local tileType = getTileTypeFromIndex(col.other, "mainTiles", world)
				friction = math.max(friction, tileType.friction or consts.defaultFriction)
				if tileType.kills and entity.health then
					entity.health = 0
				end
			end
			if col.normal.x ~= 0 then
				entity.velocity.x = 0
				collidedX = true
			elseif col.normal.y ~= 0 then
				entity.velocity.y = 0
				if col.normal.y == -1 then
					entity.onGround = true
				end
			end
		end
		if love.keyboard.isDown("space") then
			entity.jumpTimeLeft = math.max(0, entity.jumpTimeLeft - dt)
		else
			entity.jumpTimeLeft = 0
		end
		local gravityMultiplier = 1
		if not entity.onGround and entity.jumpTimeLeft > 0 and not (entity.velocity.y > 0) then
			gravityMultiplier = entityType.jumpGravityMultiplier
		end
		entity.velocity = entity.velocity + world.gravity * dt * gravityMultiplier
		local sxs = math.sign(entity.velocity.x)
		local axs = math.abs(entity.velocity.x)
		entity.velocity.x = sxs * math.max(0, axs - friction * dt)
		-- local speed = #entity.velocity
		-- if speed > 0 then
		-- 	local maxWalkSpeed = entityType.maxWalkSpeed
		-- 	speed = math.min(maxWalkSpeed, speed)
		-- 	entity.velocity = vec2.normalise(entity.velocity) * speed
		-- end
		-- Jumping feels odd when limiting speed is done properly
		entity.velocity.x = limitMagnitude(entity.velocity.x, entityType.maxWalkSpeed)
		entity.velocity.y = math.min(entity.velocity.y, entityType.maxFallSpeed)
		local changeInPositionXThisFrame = entity.position.x - prevPosX
		if entity.walkCycleTimer then
			if entity.velocity.x == 0 and not dontResetWalkTimer then
				entity.walkCycleTimer = 0
			else
				entity.walkCycleTimer = (entity.walkCycleTimer + entity.direction * move * dt / entityType.walkCycleTime) % 1
			end
		end
		entity.skidding = not collidedX and math.sign(move) ~= math.sign(entity.velocity.x) and math.abs(entity.velocity.x) >= entityType.skidSpeed and (move ~= 0 or entityType.skidWhenTryingToStop)
	end
	if player and player.position.y > world.tileMapHeight * consts.tileSize + consts.pitDeathDepth then
		player.health = 0
	end
	if player and player.health <= 0 then
		-- Game over!
		love.load({})
	end
	keyPressed, keyReleased = {}, {}
end

function love.draw()
	if not camera then return end
	love.graphics.setCanvas(contentCanvas)
	love.graphics.draw(assets.sky)
	local cameraPos = vec2.clone(player.position)
	cameraPos.x = math.max(contentCanvas:getWidth()/2, math.min(consts.tileSize*world.tileMapWidth-contentCanvas:getWidth()/2, cameraPos.x))
	cameraPos.y = math.max(contentCanvas:getHeight()/2, math.min(consts.tileSize*world.tileMapHeight-contentCanvas:getHeight()/2, cameraPos.y))
	love.graphics.translate(-cameraPos.x, -cameraPos.y)
	love.graphics.translate(contentCanvas:getWidth()/2, contentCanvas:getHeight()/2)
	for x = 0, world.tileMapWidth - 1 do
		for y = 0, world.tileMapHeight - 1 do
			love.graphics.setColor(0.5, 0.5, 0.5)
			love.graphics.draw(assets.tiles[world.backgroundTiles[x][y]], x * consts.tileSize, y * consts.tileSize)
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(assets.tiles[world.mainTiles[x][y]], x * consts.tileSize, y * consts.tileSize)
		end
	end
	for entity in world.entities:elements() do
		local entityType = registry.entityTypes[entity.type]
		local entityAsset = assets.entities[entity.type]
		local spriteWidth, spriteHeight = (entityAsset.standing or entityAsset):getDimensions()
		local x = entity.position.x - (spriteWidth - entityType.width) / 2
		local y = entity.position.y - (spriteHeight - entityType.height) / 2
		local r = 0
		local sx = entity.direction or 1
		local sy = 1
		local ox = spriteWidth / 2
		local oy = 0
		x, y = x + ox, y + oy
		local function drawPose(poseName)
			if entityAsset.info and entityAsset.info[poseName] then
				x = x + (entityAsset.info[poseName].xOffset or 0)
				y = y + (entityAsset.info[poseName].yOffset or 0)
			end
			love.graphics.draw(entityAsset[poseName], x, y, r, sx, sy, ox, oy)
		end
		if not entity.onGround and entity.velocity.y <= entityType.fallPoseSpeed and entityAsset.jumping then
			drawPose("jumping")
		elseif not entity.onGround and entity.velocity.y > entityType.fallPoseSpeed and entityAsset.falling then
			drawPose("falling")
		elseif entityAsset.skidding and entity.skidding then
			drawPose("skidding")
		elseif entityType.hasWalkCycle then
			if entity.velocity.x == 0 then
				drawPose("standing")
			else
				if entityAsset.info and entityAsset.info.walking then
					x = x + (entityAsset.info.walking.xOffset or 0)
					y = y + (entityAsset.info.walking.yOffset or 0)
				end
				love.graphics.draw(entityAsset.walking, quadreasonable.getQuad(math.floor(entity.walkCycleTimer * entityAsset.walkCycleFrames), 0, entityAsset.walkCycleFrames, 1, spriteWidth, spriteHeight, 0), x, y, r, sx, sy, ox, oy)
			end
		else
			love.graphics.draw(assets.entities[entityType], x, y, r, sx, sy, ox, oy)
			-- love.graphics.rectangle("line", getXYWH(entity))
		end
	end
	love.graphics.reset()
	love.graphics.draw(contentCanvas, 0, 0, 0, consts.contentScale)
end
