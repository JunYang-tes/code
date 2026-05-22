vim.g.mkdp_auto_close = false

vim.api.nvim_create_user_command("MarkdownPreviewDisableSyncScroll", function()
	local opt = vim.g.mkdp_preview_options
	if opt then
		vim.g.mkdp_preview_options = vim.tbl_extend("force", opt, { disable_sync_scroll = 1 })
	end
end, {})

vim.api.nvim_create_user_command("MarkdownPreviewEnableSyncScroll", function()
	local opt = vim.g.mkdp_preview_options
	if opt then
		vim.g.mkdp_preview_options = vim.tbl_extend("force", opt, { disable_sync_scroll = 0 })
	end
end, {})

vim.api.nvim_create_autocmd("BufUnload", {
	callback = function(opt)
		vim.cmd("silent call mkdp#rpc#preview_close()")
	end,
	pattern = { "*.md" },
})
