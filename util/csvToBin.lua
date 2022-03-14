return function(csv)
	local bin = ""
	for numStr in csv:gmatch("[^,\n]+") do
		bin = bin .. string.char(tonumber(numStr))
	end
	return bin
end
