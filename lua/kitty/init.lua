vim.loader.enable()

local function hyhird(tbl, ...)
  local args = { ... }
  for i, v in ipairs(args) do
    tbl[i] = v
  end
  return tbl
end

local plugin = require("magic.plugin")
plugin.use(
  "Olical/aniseed", {},
  "tpope/vim-surround", {},
  "folke/flash.nvim", { keys = {
    hyhird({ mode = { "n", "o", "x" } }, "s", function()
      return require("flash").jump()
    end),
  } },
  "JunYang-tes/nvim-window-picker", {
    version = "2.*",
    event = "VeryLazy",
    window = "window-picker",
    config = {
      hint = "floating-letter",
      filter_func = function(ids)
        return ids
      end,
    },
  },
  "folke/tokyonight.nvim", {
    opts = {},
    lazy = false,
    priority = 1000,
  },
  "mikesmithgh/kitty-scrollback.nvim", {
    enabled = true,
    lazy = false,
    cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
    config = function()
      local kitty_scrollback = require("kitty-scrollback")
      kitty_scrollback.setup()
    end,
  }
)

require("magic.face")
