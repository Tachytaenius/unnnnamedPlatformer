return function(csv)
	local bin = ""
	for numStr in csv:gmatch("[0-9]+") do
		bin = bin .. string.char(tonumber(numStr))
	end
	return bin
end
