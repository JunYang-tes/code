local ok, fold = pcall(function()
	return require("ufo")
end)
if ok then
	vim.opt.foldcolumn = "auto"
	vim.opt.fillchars = "eob: ,fold: ,foldopen:,foldclose:"
	vim.opt.foldlevel = 99
	vim.opt.foldlevelstart = 99
	vim.keymap.set("n", "zR", fold.openAllFolds)
	vim.keymap.set("n", "zr", fold.openFoldsExceptKinds)
	vim.keymap.set("n", "zM", fold.closeAllFolds)
	vim.keymap.set("n", "zm", fold.closeFoldsWith)
	fold.setup({})
end
