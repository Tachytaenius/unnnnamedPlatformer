local registry = require("registry")
local assets = require("assets")

local animatedTiles = {}

function animatedTiles:reset()
	self.timers, self.frameReferences = {}, {}
	for name, entry in pairs(registry.tileTypes) do
		if registry.animated then
			self.timers[name] = 0
		end
	end
	self:updateFrameReferences()
end

function animatedTiles:update(dt)
	for tileTypeName, tileAnimationTimer in pairs(self.timers) do
		self.timers[tileTypeName] = (tileAnimationTimer + dt) % registry[tileTypeName].animationLength
	end
	self:updateFrameReferences()
end

function animatedTiles:updateFrameReferences()
	for tileTypeName, tileAnimationTimer in pairs(self.timers) do
		local numFrames = #assets[tileTypeName] + 1 -- starts at 0
		self.frameReferences[tileTypeName] = math.floor(self.timers[tileTypeName] / numFrames) * numFrames
	end
end

return animatedTiles
