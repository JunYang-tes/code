local ok, symbols = pcall(function()
	return require("symbols-outline")
end)
if ok then
	symbols.setup({ width = 25 })
end
