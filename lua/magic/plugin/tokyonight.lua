local setup = require("tokyonight").setup
setup({
	on_highlights = function(hl, c)
		hl.DiagnosticUnnecessary = { fg = c.fg }
	end,
})
