return function(entity, type, count)
	if not entity.inventory then
		return false
	end
	local stack
	for i, v in ipairs(entity.inventory) do
		if v.type == type then
			stack = v
			break
		end
	end
	if not stack then
		stack = {type = type, count = 0}
		entity.inventory[#entity.inventory+1] = stack
	end
	stack.count = stack.count + count
	return true
end
