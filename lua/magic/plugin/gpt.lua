local ok, gpt = pcall(function()
	return require("chatgpt")
end)
if ok then
	gpt.setup({})
end
