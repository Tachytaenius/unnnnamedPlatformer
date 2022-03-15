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
		return 0
	end
	return stack.count
end
