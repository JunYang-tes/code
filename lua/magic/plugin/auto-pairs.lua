local ok, auto_pairs = pcall(function()
	return require("nvim-autopairs")
end)
local _, rule = pcall(function()
	return require("nvim-autopairs.rule")
end)
local _, conds = pcall(function()
	return require("nvim-autopairs.conds")
end)
if ok then
	auto_pairs.setup({})
	auto_pairs.add_rules({
		rule("{", "}"):with_move(conds.none),
	})
end
