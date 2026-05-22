local image = require("magic.plugin.image")

local ok, nvim_tree = pcall(function()
	return require("nvim-tree")
end)
local _, api = pcall(function()
	return require("nvim-tree.api")
end)
local _, marks = pcall(function()
	return require("nvim-tree.marks")
end)
local nui_popup = require("nui.popup")

local trash = function()
	local nodes = marks.get_marks()
	local node = api.tree.get_node_under_cursor()
	if nodes and #nodes > 0 then
		api.marks.bulk.trash()
	else
		api.fs.trash(node)
	end
end

local change_root_to_node = function()
	local node = api.tree.get_node_under_cursor()
	if node.nodes ~= nil then
		api.tree.change_root_to_node()
	end
	api.node.open.edit(node)
end

local open_in_oil = function()
	local node = api.tree.get_node_under_cursor()
	if node then
		local path
		if node.type == "directory" then
			path = node.absolute_path
		else
			path = vim.fn.fnamemodify(node.absolute_path, ":h")
		end
		local oil = require("oil")
		if vim.api.nvim_buf_get_option(0, "filetype") == "NvimTree" then
			vim.cmd("wincmd p")
		end
		oil.open(path)
	end
end

local preview = function()
	local node = api.tree.get_node_under_cursor()
	local event = require("nui.utils.autocmd")
	local path = node.absolute_path
	local line, column = unpack(vim.api.nvim_win_get_cursor(0))
	if node.type == "file" then
		local popup = nui_popup({
			relative = "editor",
			position = { row = line, col = column },
			enter = true,
			size = "30%",
			border = { style = "rounded" },
			anchor = "NE",
		})
		popup:mount()
		vim.defer_fn(function()
			image.preview(popup.winid, popup.bufnr, path)
		end, 50)
		vim.defer_fn(function()
			local ns_id = nil
			ns_id = vim.on_key(function()
				popup:hide()
				popup:unmount()
				vim.on_key(nil, ns_id)
			end)
		end, 100)
	end
end

if ok then
	nvim_tree.setup({
		on_attach = function(bufnr)
			local function keymap(mode, lhs, rhs, help)
				vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = help })
			end
			keymap("n", "K", preview)
			keymap("n", "[c", api.node.navigate.git.prev)
			keymap("n", "]c", api.node.navigate.git.next)
			keymap("n", "<space>", api.marks.toggle, "Select")
			keymap("n", "c", api.fs.copy.node, "Copy")
			keymap("n", "?", api.tree.toggle_help, "Help")
			keymap("n", "a", api.fs.create, "Create file")
			keymap("n", "x", api.fs.cut, "Cut")
			keymap("n", "d", trash, "Delete file(s)")
			keymap("n", "p", api.fs.paste, "Paste")
			keymap("n", "R", api.tree.reload, "Reload")
			keymap("n", "r", api.fs.rename, "Rename")
			keymap("n", "q", api.tree.close, "Close")
			keymap("n", "l", api.node.open.edit, "Edit")
			keymap("n", "o", open_in_oil, "Open in Oil")
			keymap("n", "h", api.node.navigate.parent_close, "Close parent directory")
			keymap("n", ">", api.node.navigate.sibling.next, "Navigate to next sibling")
			keymap("n", "<", api.node.navigate.sibling.prev, "Navigate to previous sibling")
			keymap("n", "-", api.tree.change_root_to_parent, "Change root to parent")
			keymap("n", "<cr>", change_root_to_node, "Change root to current directory")
			keymap("n", "e", api.node.open.vertical, "Edit vertically")
		end,
		git = { ignore = false },
		update_focused_file = { enable = true, ignore_list = { "node_modules" }, update_cwd = false },
		filters = { dotfiles = false, git_clean = false },
	})
end
