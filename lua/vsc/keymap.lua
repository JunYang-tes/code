print("load-keymap")

local util = require("magic.util")
local vscode = require("vscode-neovim")

local function map(from, to)
  util.noremap(from, to)
end

local function nmap(from, to)
  util.nnoremap(from, to)
end

local function map_cmd(mode, key, cmd)
  vim.keymap.set(mode, key, "<cmd>" .. cmd .. "<cr>")
end

local function map_action(mode, key, action, opts)
  vim.keymap.set(mode, key, function()
    vscode.action(action, opts)
  end)
end

map("<space><tab>", "<cmd>b#<CR>")
map("j", "gj")
map("k", "gk")
nmap("[t", "tabpre")
nmap("]t", "tabnext")
nmap("[h", "Gitsign prev_hunk")
nmap("]h", "Gitsign next_hunk")
map_action("n", "ge", "workbench.view.explorer")
map_action("n", "[d", "editor.action.marker.next")
map_action("n", "]d", "editor.action.marker.prev")
map_action("n", "<leader>lr", "editor.action.rename")
map_action("n", "<leader>sr", "find-it-faster.resume_search")
map_action("n", "<leader>sf", "find-it-faster.findFiles")
map_action("n", "<leader>sg", "find-it-faster.findWithinFiles")
map_action("n", "<leader>ss", "find-it-faster.pickFileFromGitStatus")
map_action("n", "<leader>so", "editor.action.accessibleViewGoToSymbol")
map_action("n", "<leader>sb", "workbench.action.quickOpenNavigateNextInFilePicker")
map_action("n", "<leader>lf", "editor.action.formatDocument")
vim.keymap.set("v", "p", "\"_dP", { noremap = true })
