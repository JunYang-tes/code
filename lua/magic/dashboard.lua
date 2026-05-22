local util = require("magic.util")

local image_instance = nil
local image_config = nil
local dashboard_buf = nil
local autocmd_ids = {}

local function is_floating_window(win)
	if win and win >= 0 then
		local config = vim.api.nvim_win_get_config(win)
		return config.relative and config.relative ~= ""
	end
	return false
end

local function hide_image()
	if image_instance then
		image_instance:clear()
		image_instance = nil
	end
end

local function show_image()
	if image_config and not image_instance then
		local image = require("image")
		local instance = image.from_file(image_config.path, {
			x = image_config.x,
			y = image_config.y,
			width = image_config.w,
			height = image_config.h,
			window = image_config.opts.window,
			buffer = image_config.opts.buffer,
		})
		if instance then
			image_instance = instance
			instance:render()
		end
	end
end

local function get_recent_files(limit)
	local cwd = vim.fn.getcwd()
	local files = {}
	for _, file in ipairs(vim.v.oldfiles or {}) do
		if #files < limit and file:find(cwd, 1, true) and util.exists(file) then
			table.insert(files, file)
		end
	end
	return files
end

local function open_file(file)
	vim.cmd("edit " .. file)
end

local function cleanup_autocmd()
	for _, id in ipairs(autocmd_ids) do
		vim.api.nvim_del_autocmd(id)
	end
	autocmd_ids = {}
end

local function render_dashboard()
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_get_current_win()
	local total_width = vim.api.nvim_win_get_width(win)
	local win_height = vim.api.nvim_win_get_height(win)
	local win_info = vim.fn.getwininfo(win)[1]
	local text_off = win_info.textoff or 0
	local win_width = total_width - text_off

	local cwd = vim.fn.getcwd()
	local files = get_recent_files(10)
	local avatar_path = util.get_path("avatar.jpeg")

	vim.api.nvim_win_set_buf(win, buf)

	local img_h = 10
	local img_w = 22
	local content_w = 50
	local left_padding = math.max(0, math.floor((win_width - content_w) / 2))
	local top_padding = math.max(0, math.floor((win_height - 26) / 2))
	local indent = string.rep(" ", left_padding)
	local empty_line = string.rep(" ", win_width)

	local lines = {}

	for _ = 1, top_padding do
		table.insert(lines, "")
	end

	for _ = 1, img_h + 2 do
		table.insert(lines, empty_line)
	end

	table.insert(lines, indent .. "󰚝  Project: " .. cwd)
	table.insert(lines, "")

	table.insert(lines, indent .. "󰈚  Recent Files")
	if #files > 0 then
		for i, file in ipairs(files) do
			local short_path = file:sub(#cwd + 2)
			local display_text = string.format("   [%d] %s", i - 1, short_path)
			table.insert(lines, indent .. display_text)
		end
	else
		table.insert(lines, indent .. "   No recent files here.")
	end
	table.insert(lines, "")

	table.insert(lines, indent .. "󱁤  Actions")
	local shortcuts = {
		{ "f", "Find Files" },
		{ "h", "Frecency Search" },
		{ "e", "New File" },
		{ "q", "Quit" },
	}
	for _, shortcut in ipairs(shortcuts) do
		table.insert(lines, indent .. string.format("   [%s] %s", shortcut[1], shortcut[2]))
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	for i, content in ipairs(lines) do
		local row = i - 1
		local idx = content:find("%[")
		if idx then
			vim.api.nvim_buf_add_highlight(buf, -1, "Directory", row, idx - 1, idx + 2)
		end
		if content:find("󰈚") or content:find("󱁤") or content:find("󰚝") then
			vim.api.nvim_buf_add_highlight(buf, -1, "Keyword", row, 0, -1)
		end
	end

	vim.bo[buf].modifiable = false
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].filetype = "dashboard"
	vim.bo[buf].bufhidden = "wipe"

	dashboard_buf = buf
	table.insert(
		autocmd_ids,
		vim.api.nvim_create_autocmd("BufWipeout", {
			buffer = buf,
			callback = function()
				hide_image()
				image_config = nil
				dashboard_buf = nil
				cleanup_autocmd()
			end,
		})
	)
	vim.wo.number = false
	vim.wo.relativenumber = false
	vim.wo.list = false
	vim.wo.fillchars = "eob: "
	vim.wo.wrap = false

	if util.exists(avatar_path) then
		local curr_total_width = vim.api.nvim_win_get_width(win)
		local curr_win_info = vim.fn.getwininfo(win)[1]
		local curr_usable_width = curr_total_width - (curr_win_info.textoff or 0)
		local img_x = math.floor((curr_usable_width - img_w) / 2)
		image_config = {
			path = avatar_path,
			opts = { window = win, buffer = buf },
			x = img_x,
			y = top_padding + 1,
			w = img_w,
			h = img_h,
		}
		vim.defer_fn(function()
			show_image()
		end, 100)
	end

	local map_opts = { buffer = buf, nowait = true, silent = true }
	for i, file in ipairs(files) do
		vim.keymap.set("n", tostring(i - 1), function()
			open_file(file)
		end, map_opts)
	end
	vim.keymap.set("n", "f", function()
		vim.cmd("Telescope find_files")
	end, map_opts)
	vim.keymap.set("n", "h", function()
		vim.cmd("Telescope frecency workspace=CWD")
	end, map_opts)
	vim.keymap.set("n", "e", function()
		vim.cmd("enew")
	end, map_opts)
	vim.keymap.set("n", "q", function()
		vim.cmd("quit")
	end, map_opts)
end

local function setup()
	cleanup_autocmd()

	table.insert(
		autocmd_ids,
		vim.api.nvim_create_autocmd("WinEnter", {
			callback = function()
				if dashboard_buf and is_floating_window(0) then
					hide_image()
				end
			end,
		})
	)

	table.insert(
		autocmd_ids,
		vim.api.nvim_create_autocmd("WinLeave", {
			callback = function()
				if dashboard_buf then
					local next_win = vim.fn.winnr("#")
					local next_win_id = vim.fn.win_getid(next_win)
					if image_config and not is_floating_window(next_win_id) then
						show_image()
					end
				end
			end,
		})
	)

	table.insert(
		autocmd_ids,
		vim.api.nvim_create_autocmd("WinClosed", {
			callback = function()
				if dashboard_buf and image_config and not is_floating_window(0) then
					show_image()
				end
			end,
		})
	)

	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			if
				vim.fn.argc() == 0
				and vim.fn.line2byte(vim.fn.line("$")) == -1
				and vim.api.nvim_buf_get_name(0) == ""
			then
				render_dashboard()
			end
		end,
	})
end

return { setup = setup }
