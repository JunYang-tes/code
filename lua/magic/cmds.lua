local util = require("magic.util")

vim.api.nvim_create_user_command("PasteImg", function(info)
	if #info.fargs == 0 then
		print("Usage: PasteImg [filename] [path]")
		return
	end
	local filename = info.fargs[1]
	local path = info.fargs[2] or vim.fn.expand("%:p:h")
	local paste_img = require("clipboard-image.paste").paste_img
	paste_img({ img_name = filename, img_dir = path })
end, { desc = "Paste Image", nargs = "*" })

vim.api.nvim_create_user_command("Search", function()
	require("spectre").toggle()
end, { desc = "Search & Replace", nargs = 0 })

vim.api.nvim_create_user_command("OpenLog", function()
	local path = vim.fn.stdpath("log")
	local iter = vim.iter(vim.fn.readdir(path))
	local files = iter:map(function(f)
		return path .. "/" .. f
	end):filter(function(f)
		return string.match(f, "%.log$")
	end)
	util.pick(files:totable(), "Select log", function(file)
		vim.cmd("e " .. file)
	end)
end, { desc = "Open log", nargs = 0 })
