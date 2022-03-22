local vec2 = require("lib.mathsies").vec2

local consts = {}

consts.identity = "platformer"
consts.tickLength = 1/30
consts.maxTicksPerFrame = 3
consts.contentWidth = 384
consts.contentHeight = 256
consts.contentScale = 3

consts.tileSize = 16
consts.pitDeathDepth = 32
consts.defaultFriction = 0
consts.defaultGravity = vec2(0, 300)

return consts
