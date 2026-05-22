local ok, s = pcall(function()
	return require("lsp_signature")
end)
if ok then
	s.setup({ floating_window = false })
end
