local ok, telescope = pcall(function()
	return require("telescope")
end)
if ok then
	telescope.setup({
		defaults = {
			vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				"--hidden",
				"--follow",
				"-g",
				"!.git/",
			},
			layout_strategy = "horizontal",
			sorting_strategy = "ascending",
			layout_config = { horizontal = { prompt_position = "top" } },
		},
		extensions = {
			recent_files = { only_cwd = true },
			aerial = {},
			media_files = { filetypes = { "png", "jpg", "jpeg" }, find_cmd = "rg" },
		},
	})
	pcall(function()
		telescope.load_extension("recent_files")
	end)
	pcall(function()
		telescope.load_extension("media_files")
	end)
end
