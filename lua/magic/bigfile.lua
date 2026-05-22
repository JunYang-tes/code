local util = require("magic.util")

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(opt)
		if util.is_a_big_file(opt.buf) then
			vim.schedule(function()
				vim.lsp.buf_detach_client(opt.buf, opt.data.client_id)
			end)
		end
	end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(opt)
		if util.is_a_big_file(opt.buf) and util.has_long_line(opt.buf) then
			vim.api.nvim_buf_set_option(opt.buf, "filetype", "txt")
			vim.cmd("set wrap")
		end
	end,
})
