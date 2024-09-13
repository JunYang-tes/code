-- Welcome to your magic kit!
-- This is the first file Neovim will load.
-- We'll ensure we have a plugin manager and Aniseed.
-- This will allow us to load more Fennel based code and download more plugins.

-- Make some modules easier to access.
local execute = vim.api.nvim_command
local fn = vim.fn
local fmt = string.format

function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local aniseed = fn.stdpath("data") .. "/lazy/aniseed"
if not vim.loop.fs_stat(aniseed) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/Olical/aniseed",
    aniseed,
  })
end
vim.opt.rtp:prepend(aniseed)

-- Enable Aniseed's automatic compilation and loading of Fennel source code.
-- Aniseed looks for this when it's loaded then loads the rest of your
-- configuration if it's set.
local input  = script_path() .. "fnl"
if(vim.g.vscode) then
  vim.g["aniseed#env"] = {
    module = "vsc.init",
    input = input
  }
else
  vim.g["aniseed#env"] = {
    module = "magic.init",
    input = input
  }
end

-- Now head to fnl/magic/init.fnl to continue your journey.
-- Try pressing gf on the file path to [g]o to the [f]ile.
