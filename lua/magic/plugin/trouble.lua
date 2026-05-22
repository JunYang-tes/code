local ok, t = pcall(function()
	return require("trouble")
end)
if ok then
	t.setup()
end
