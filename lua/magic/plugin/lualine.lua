local model = require("magic.model")

local ok, lualine = pcall(function()
	return require("lualine")
end)
if ok then
	lualine.setup({
		sections = {
			lualine_c = {
				"filename",
				model.get_model,
				function()
					return require("lsp-progress").progress()
				end,
			},
		},
	})
end
model.add_on_change(require("lualine").refresh)
vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
vim.api.nvim_create_autocmd("User", {
	group = "lualine_augroup",
	pattern = "LspProgressStatusUpdated",
	callback = require("lualine").refresh,
})
