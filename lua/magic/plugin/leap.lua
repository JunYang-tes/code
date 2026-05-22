local ok, leap = pcall(function()
	return require("leap")
end)
if ok then
	leap.add_default_mappings()
end
