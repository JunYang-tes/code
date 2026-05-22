local model = require("magic.model")
local util = require("magic.util")

local function map(from, to)
	util.noremap(from, to)
end
local function nmap(from, to)
	util.nnoremap(from, to)
end
local function tnomap(from, to)
	vim.api.nvim_set_keymap("t", from, to, {})
end
local function map_cmd(mode, key, cmd)
	vim.keymap.set(mode, key, "<cmd>" .. cmd .. "<cr>")
end
local function map_plug(mode, key, cmd)
	vim.keymap.set(mode, key, "<Plug>(" .. cmd .. ")")
end

map("<leader>wc", "<C-w>c")
map("<leader>wh", "<C-w>h")
map("<leader>wl", "<C-w>l")
map("<leader>wk", "<C-w>k")
map("<leader>wj", "<C-w>j")
map("<space><tab>", "<cmd>b#<CR>")
map_cmd({ "n", "i", "v" }, "<c-s>", "w")
map_cmd({ "n", "i", "v" }, "<c-S>", "wa")
map_cmd("n", "<leader>wz", "WindowsMaximize")
map_cmd("n", "<leader>w=", "WindowsEqualize")
map("ge", "<cmd>NvimTreeToggle<CR>")
map_cmd("n", "[d", "Lspsaga diagnostic_jump_prev")
map_cmd("n", "]d", "Lspsaga diagnostic_jump_next")
map("[e", "<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>")
map("]e", "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>")
map("j", "gj")
map("k", "gk")
nmap("[t", "tabpre")
nmap("]t", "tabnext")
nmap("[h", "Gitsign prev_hunk")
nmap("]h", "Gitsign next_hunk")
map_cmd("n", "gd", "Lspsaga goto_definition")
map_cmd("n", "gt", "Lspsaga goto_type_definition")
nmap("gD", "lua vim.lsp.buf.declaration()")
map_cmd("n", "gr", "Lspsaga finder ref ")
nmap("gi", "lua vim.lsp.buf.implementation()")
nmap("<c-k>", "lua vim.lsp.buf.signature_help()")
nmap(
	"<leader>ap",
	"lua require('ai-assistant.runner')[\"run-with-buf\"](vim.api.nvim_get_current_buf(),'pair-programmer')"
)
nmap("<leader>ag", "lua require('ai-assistant.runner')[\"run-general\"]()")
nmap("<leader>at", "lua require('ai-assistant.runner')[\"run-translator\"]()")
nmap("<leader>as", "lua require('ai-assistant.runner')[\"run-without-buf\"]('secretary')")
map_cmd("n", "<leader>lr", "Lspsaga rename")
map_cmd("n", "<leader>la", "Lspsaga code_action")
map_cmd("n", "<leader>z", "ZenMode")
map_cmd("n", "<leader>lf", "lua vim.lsp.buf.format()")
map_cmd("n", "<leader>sr", "Telescope resume")
map_cmd("n", "<leader>sf", "Telescope find_files")
map_cmd("n", "<leader>sg", "Telescope live_grep ")
map_cmd("n", "<leader>sb", "Telescope buffers")
map_cmd("n", "<leader>sc", "Telescope commands")
map_cmd("n", "<leader>sq", "Telescope quickfix")
map_cmd("n", "<leader>ss", "Telescope git_status")
map_cmd("n", "<leader>sh", "Telescope frecency workspace=CWD")
map_cmd("n", "<leader>sla", "Telescope lsp_code_actions")
map_cmd("n", "<leader>slr", "Telescope lsp_references")
map_cmd("n", "<leader>so", "Telescope aerial")
map_plug("n", "s", "leap-forward-to")
map_plug("n", "S", "leap-backward-to")
map_plug("n", "gs", "leap-from-window")
map_cmd({ "n", "i" }, "<F2>", "lua require('FTerm').toggle()")
tnomap("<F2>", "<C-\\><C-n><cmd>lua require('FTerm').toggle()<cr>")

vim.keymap.set("n", "<leader>wf", function()
	local picker = require("window-picker")
	local win_id = picker.pick_window({ filter_rules = { bo = { filetype = {}, buftype = {} } } })
	vim.api.nvim_set_current_win(win_id)
end)

vim.keymap.set("n", "<leader>ws", function()
	local picker = require("window-picker")
	local curr_buf = vim.api.nvim_win_get_buf(0)
	local win_id = picker.pick_window({ filter_rules = { bo = { filetype = {}, buftype = {} } } })
	local target_buf = vim.api.nvim_win_get_buf(win_id)
	vim.api.nvim_win_set_buf(0, target_buf)
	vim.api.nvim_win_set_buf(win_id, curr_buf)
end)

vim.keymap.set("n", "[b", function()
	require("buffer_browser").prev()
end)

vim.keymap.set("n", "]b", function()
	require("buffer_browser").next()
end)

vim.keymap.set("n", "K", function()
	local folded = vim.fn.foldclosed(vim.fn.line(".")) > 0
	local ufo = require("ufo")
	if folded then
		ufo.peekFoldedLinesUnderCursor(true)
	else
		vim.api.nvim_command("Lspsaga hover_doc")
	end
end)

vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>", { noremap = true })

vim.keymap.set("v", "p", '"_dP', { noremap = true })
vim.api.nvim_command("imap <script><silent><nowait><expr> <C-l> codeium#Accept()")

vim.defer_fn(function()
	vim.keymap.set({ "n", "v" }, "<leader>aa", function()
		local plugin = model.get_prefered_ai_plugin()
		if plugin == "avante" then
			vim.cmd("AvanteAsk")
		elseif plugin == "companion" then
			vim.cmd("CodeCompanionChat Toggle")
		end
	end)
	vim.keymap.set({ "n", "v" }, "<leader>ae", function()
		local plugin = model.get_prefered_ai_plugin()
		if plugin == "avante" then
			vim.cmd("AvanteEdit")
		elseif plugin == "companion" then
			vim.cmd("CodeCompanionChat Add")
		end
	end)
	vim.keymap.set({ "n", "v" }, "<leader>ac", function()
		local plugin = model.get_prefered_ai_plugin()
		if plugin == "avante" then
			vim.cmd("AvanteChat")
		elseif plugin == "companion" then
			vim.cmd("CodeCompanionChat Toggle")
		end
	end)
end, 100)
