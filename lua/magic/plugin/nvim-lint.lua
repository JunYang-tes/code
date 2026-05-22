local ok, lint = pcall(function()
	return require("lint")
end)
if ok then
	lint.linters_by_ft = {
		typescript = { "eslint" },
		javascript = { "eslint" },
	}
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		callback = function()
			pcall(lint.try_lint)
		end,
	})
end
