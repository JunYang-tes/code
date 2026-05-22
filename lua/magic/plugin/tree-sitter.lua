local ok, cfg = pcall(function()
	return require("nvim-treesitter.configs")
end)
if ok then
	cfg.setup({
		ensure_installed = { "typescript", "css", "javascript", "markdown", "markdown_inline", "kotlin" },
		highlight = { enable = true },
		indent = { enable = true },
		textobjects = {
			select = {
				enable = true,
				keymaps = {
					af = "@function.outer",
					if_ = "@function.inner",
				},
			},
		},
	})
end
