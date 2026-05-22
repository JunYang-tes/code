local ok, cfg = pcall(function()
	return require("illuminate")
end)
if ok then
	cfg.configure({
		providers = { "lsp", "treesitter" },
		under_cursor = true,
	})
end
