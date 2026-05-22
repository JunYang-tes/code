vim.loader.enable()

vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.updatetime = 500
vim.opt.timeoutlen = 500
vim.opt.sessionoptions = "blank,curdir,folds,help,tabpages,winsize"
vim.opt.inccommand = "split"
vim.opt.signcolumn = "yes"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.cmd("set formatoptions-=o")
vim.opt.expandtab = true
vim.opt.relativenumber = true
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
})

local function hyhird(tbl, ...)
  local args = { ... }
  for i, v in ipairs(args) do
    tbl[i] = v
  end
  return tbl
end

vim.g.mapleader = ","
require("vsc.keymap")

local plugin = require("magic.plugin")
plugin.use(
  "tpope/vim-surround", {},
  "stevearc/oil.nvim", {
    config = function()
      require("oil").setup({})
      vim.keymap.set("n", "-", "<cmd>Oil<cr>")
    end,
  },
  "lewis6991/gitsigns.nvim", {
    config = function()
      local gitsigns = require("gitsigns")
      gitsigns.setup({})
    end,
  },
  "folke/flash.nvim", { keys = {
    hyhird({ mode = { "n", "o", "x" } }, "s", function()
      return require("flash").jump()
    end),
    hyhird({ mode = { "n", "o", "x" } }, "S", function()
      return require("flash").treesitter()
    end),
  } }
)
