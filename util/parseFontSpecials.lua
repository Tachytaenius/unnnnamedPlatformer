local assets = require("assets")

return function(text)
	for _, special in ipairs(assets.font.info.specials) do
		text = text:gsub(special.pattern, special.replace)
	end
	return text
end
