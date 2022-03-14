-- Quadreasonable is a quads library for spritesheets in LÖVE
-- By Tachytaenius
-- Version 1

-- TODO: Verify that claim below!

local quadreasonable = {} -- Quadtastic was already taken ;-)

local quads = {}
quadreasonable.quads = quads

local newQuad = love.graphics.newQuad

function quadreasonable.getQuad(spriteX, spriteY, spriteCountX, spriteCountY, spriteWidth, spriteHeight, padding)
	padding = padding or 0 -- NOTE: 2 works when you're rotating, scaling etc your drawcalls and want to avoid any bleeding?
	local current
	
	if not quads[spriteX] then
		quads[spriteX] = {}
	end
	current = quads[spriteX]
	
	if not current[spriteY] then
		current[spriteY] = {}
	end
	current = current[spriteY]
	
	if not current[spriteWidth] then
		current[spriteWidth] = {}
	end
	current = current[spriteWidth]
	
	if not current[spriteHeight] then
		current[spriteHeight] = {}
	end
	current = current[spriteHeight]
	
	if not current[spriteCountX] then
		current[spriteCountX] = {}
	end
	current = current[spriteCountX]
	
	if not current[spriteCountY] then
		current[spriteCountY] = {}
	end
	current = current[spriteCountY]
	
	if not current[padding] then
		local x = spriteX * spriteWidth + (spriteX + 1) * padding
		local y = spriteY * spriteHeight + (spriteY + 1) * padding
		local sheetWidth = spriteCountX * spriteWidth + (spriteCountX + 1) * padding
		local sheetHeight = spriteCountY * spriteHeight + (spriteCountY + 1) * padding
		current[padding] = newQuad(x, y, spriteWidth, spriteHeight, sheetWidth, sheetHeight)
	end
	return current[padding]
end

function quadreasonable.pregenerate(spriteWidth, spriteHeight, spriteCountX, spriteCountY, padding)
	for x = 0, spriteCountX - 1 do
		for y = 0, spriteCountY - 1 do
			quadreasonable.getQuad(x, y, spriteWidth, spriteHeight, spriteCountX, spriteCountY, padding)
		end
	end
end

return quadreasonable

-- My dog used to chase people on bikes a lot.
-- Eventually I had to confiscate his collection.
