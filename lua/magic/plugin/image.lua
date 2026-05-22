local util = require("magic.util")

local image = require("image")
local image_util = require("image.utils")
image.setup(
	{ integrations = { markdown = { enabled = false } } },
	{ hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" } }
)

util.monkey_patch(image_util.magic, "is_image", function(_, _, path)
	local img_postfix = { "%.png", "%.ppm", "%.tga", "%.svg", "%.gif", "%.jpg", "%.jpeg", "%.webp" }
	for _, ext in ipairs(img_postfix) do
		if string.match(path, ext) then
			return true
		end
	end
	return false
end)

local function preview(winid, bufnr, path)
	local instance = image.from_file(path, { x = 0, y = 0, window = winid })
	if instance then
		instance:render()
	end
end

return { preview = preview }
