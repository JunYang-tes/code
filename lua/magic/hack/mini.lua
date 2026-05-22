pcall(function()
	local mini = require("noice.view.backend.mini")
	local focused_ft = ""

	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = "*",
		callback = function()
			focused_ft = vim.api.nvim_buf_get_option(0, "filetype")
		end,
	})

	local can_hide = mini.can_hide
	mini.can_hide = function(self, message)
		return can_hide(self, message) and focused_ft ~= "noice"
	end
end)
