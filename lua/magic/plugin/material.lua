local ok, material = pcall(function()
	return require("material")
end)
if ok then
	material.setup({
		custom_highlights = { FloatBorder = { fg = "#1A1A1A" } },
		borders = true,
		high_visibility = { darker = true },
	})
	vim.g.material_style = "darker"
	vim.cmd("colorscheme material")
end
