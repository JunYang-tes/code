local source = debug.getinfo(1, "S").source:sub(2)
vim.g.magic_root = vim.fn.fnamemodify(source, ":p:h")
package.path = vim.g.magic_root .. "/lua/?.lua;" .. vim.g.magic_root .. "/lua/?/init.lua;" .. package.path

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--depth=1",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
vim.opt.rtp:prepend(vim.g.magic_root)

if vim.env.KITTY_SCROLLBACK_NVIM == "true" then
  require("kitty")
elseif vim.g.vscode then
  require("vsc")
else
  require("magic")
end
