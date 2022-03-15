-- Used for debugging only

local getTime, insert, remove = love.timer.getTime, table.insert, table.remove
local timerStackValues, timerStackNames = {}, {}

function s(name)
	name = name or "unnamed"
	print(name)
	insert(timerStackValues, getTime())
	insert(timerStackNames, name)
end
function e(name)
	name = name or "unnamed"
	local nameFromStack = remove(timerStackNames)
	assert(name == nameFromStack, name .. " ~= " .. nameFromStack)
	print(name .. ": " .. getTime() - remove(timerStackValues))
end
