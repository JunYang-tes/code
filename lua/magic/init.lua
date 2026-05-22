vim.loader.enable()

require("magic.diagnostics")

vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.updatetime = 500
vim.opt.timeoutlen = 400
vim.opt.sessionoptions = "blank,curdir,folds,help,tabpages,winsize"
vim.opt.inccommand = "split"
vim.opt.signcolumn = "yes"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.laststatus = 3
vim.opt.title = true
vim.opt.undofile = true
vim.cmd("set formatoptions-=o")
vim.opt.expandtab = true
vim.opt.relativenumber = true
vim.diagnostic.config({
	virtual_text = false,
	signs = true,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "html", "css" },
	callback = function()
		vim.opt_local.iskeyword:append("-")
	end,
})

local function hyhird(tbl, ...)
	local args = { ... }
	for i, v in ipairs(args) do
		tbl[i] = v
	end
	return tbl
end

vim.g.mapleader = ","
require("magic.keymap")

local use_coq = os.getenv("COQ") ~= nil
local use_blink = os.getenv("BLINK") ~= nil
local use_cmp = not use_coq and not use_blink

local use_companion = os.getenv("COMPANION") ~= nil
local use_avante = not use_companion
local use_copilot = os.getenv("COPILOT") == "1"
local has_yarn = vim.fn.executable("yarn") == 1
local has_cargo = vim.fn.executable("cargo") == 1
local has_image_support = vim.env.KITTY_WINDOW_ID ~= nil
	or vim.env.WEZTERM_PANE ~= nil
	or (vim.env.TERM or ""):find("sixel")
	or vim.fn.executable("chafa") == 1
	or vim.fn.executable("viu") == 1
	or vim.fn.executable("ueberzug") == 1

local plugin = require("magic.plugin")
plugin.use(
	"Olical/aniseed",
	{},
	"Olical/nvim-local-fennel",
	{},
	"lewis6991/gitsigns.nvim",
	{
		config = function()
			local gitsigns = require("gitsigns")
			gitsigns.setup({})
		end,
	},
	"sindrets/diffview.nvim",
	{},
	"folke/trouble.nvim",
	{ mod = "trouble" },
	"folke/tokyonight.nvim",
	{ mod = "tokyonight" },
	"folke/flash.nvim",
	{
		keys = {
			hyhird({ mode = { "n", "o", "x" } }, "s", function()
				return require("flash").jump()
			end),
			hyhird({ mode = { "n", "o", "x" } }, "S", function()
				return require("flash").treesitter()
			end),
		},
	},
	"hrsh7th/cmp-buffer",
	{ cond = use_cmp },
	"hrsh7th/cmp-cmdline",
	{ cond = use_cmp },
	"hrsh7th/cmp-nvim-lsp",
	{ cond = use_cmp },
	"hrsh7th/cmp-path",
	{ cond = use_cmp },
	"hrsh7th/nvim-cmp",
	{ cond = use_cmp, mod = "nvim-cmp" },
	"L3MON4D3/LuaSnip",
	{ cond = use_cmp },
	"Exafunction/codeium.vim",
	{ event = "BufEnter", cond = not use_copilot },
	"ms-jpq/coq_nvim",
	{
		cond = use_coq,
		branch = "coq",
		init = function()
			vim.g.coq_settings =
				{ auto_start = true, display = { pum = { fast_close = false } }, keymap = { pre_select = true } }
		end,
		lazy = false,
	},
	"nvimdev/lspsaga.nvim",
	{ lazy = false, mod = "lspsaga", requires = { "nvim-tree/nvim-web-devicons" } },
	"yioneko/nvim-vtsls",
	{
		config = function()
			require("vtsls").config({})
		end,
	},
	"windwp/nvim-autopairs",
	{ mod = "auto-pairs" },
	"mbbill/undotree",
	{ mod = "undotree" },
	"neovim/nvim-lspconfig",
	{ mod = "lspconfig" },
	"nvim-lualine/lualine.nvim",
	{ mod = "lualine" },
	"nvim-lua/plenary.nvim",
	{},
	"nvim-telescope/telescope.nvim",
	{ mod = "telescope", requires = { { "nvim-lua/popup.nvim" }, { "nvim-lua/plenary.nvim" } } },
	"nvim-telescope/telescope-frecency.nvim",
	{
		config = function()
			require("telescope").load_extension("frecency")
		end,
	},
	"nvim-treesitter/nvim-treesitter",
	{
		mod = "tree-sitter",
		branch = "main",
		build = "TSUpdate",
		run = function()
			require("nvim-treesitter.install").update({ with_sync = true })
		end,
	},
	"nvim-treesitter/nvim-treesitter-context",
	{ opts = { enable = false } },
	"nvim-treesitter/nvim-treesitter-textobjects",
	{ branch = "main" },
	"RRethy/vim-illuminate",
	{ mod = "vim-illuminate" },
	"JoosepAlviste/nvim-ts-context-commentstring",
	{},
	"numToStr/Comment.nvim",
	{
		config = function()
			local setup = require("Comment").setup
			local create_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook
			setup({ pre_hook = create_hook() })
		end,
	},
	"lukas-reineke/indent-blankline.nvim",
	{
		config = function()
			require("ibl").setup({})
		end,
	},
	"github/copilot.vim",
	{ cond = use_copilot },
	"tpope/vim-repeat",
	{},
	"guns/vim-sexp",
	{ lazy = false },
	"tpope/vim-sexp-mappings-for-regular-people",
	{ mod = "sexp", lazy = false },
	"tpope/vim-surround",
	{},
	"folke/zen-mode.nvim",
	{},
	"nvim-tree/nvim-web-devicons",
	{},
	"ray-x/lsp_signature.nvim",
	{ mod = "lsp_signature", cond = false },
	"linrongbin16/lsp-progress.nvim",
	{
		config = function()
			require("lsp-progress").setup({})
		end,
	},
	"eraserhd/parinfer-rust",
	{ run = "cargo build --release", cond = has_cargo },
	"mfussenegger/nvim-lint",
	{ mod = "nvim-lint" },
	"anuvyklack/windows.nvim",
	{ requires = { "anuvyklack/middleclass" }, config = { autowidth = { enable = false } } },
	"nvim-telescope/telescope-media-files.nvim",
	{},
	"kevinhwang91/nvim-ufo",
	{ requires = "kevinhwang91/promise-async", mod = "fold" },
	"luukvbaal/statuscol.nvim",
	{ mod = "statuscol" },
	"williamboman/mason.nvim",
	{
		config = function()
			require("mason").setup({})
		end,
		run = ":MasonUpdate",
	},
	"JunYang-tes/nvim-window-picker",
	{
		version = "2.*",
		event = "VeryLazy",
		window = "window-picker",
		config = {
			hint = "floating-letter",
			filter_func = function(winids)
				return vim.tbl_filter(function(winid)
					local config = vim.api.nvim_win_get_config(winid)
					return config.focusable
				end, winids)
			end,
		},
	},
	"bfredl/nvim-luadev",
	{},
	"cshuaimin/ssr.nvim",
	{},
	"numtostr/FTerm.nvim",
	{},
	"lambdalisue/suda.vim",
	{},
	"NMAC427/guess-indent.nvim",
	{
		config = function()
			require("guess-indent").setup({})
		end,
	},
	"nvim-tree/nvim-tree.lua",
	{ mod = "nvim-tree" },
	"JunYang-tes/markdown-preview.nvim",
	{ cmd = { "MarkdownPreview" }, build = "cd app && yarn install", mod = "markdown-preview", ft = { "markdown" }, cond = has_yarn },
	"vhyrro/luarocks.nvim",
	{ priority = 1001, opts = { rocks = { "magick" } } },
	"3rd/image.nvim",
	{ dependencies = { "luarocks.nvim" }, mod = "image", cond = has_image_support },
	"MunifTanjim/nui.nvim",
	{},
	"stevearc/aerial.nvim",
	{
		config = function()
			vim.keymap.set("n", "go", "<cmd>AerialToggle!<cr>")
			require("aerial").setup()
		end,
	},
	"windwp/nvim-ts-autotag",
	{
		config = function()
			require("nvim-ts-autotag").setup({
				opts = { enable_close = true, enable_rename = true, enable_close_on_slash = false },
			})
		end,
	},
	"MysticalDevil/inlay-hints.nvim",
	{
		config = function()
			require("inlay-hints").setup({})
		end,
	},
	"akinsho/flutter-tools.nvim",
	{
		config = function()
			require("flutter-tools").setup({})
		end,
	},
	"MeanderingProgrammer/render-markdown.nvim",
	{
		config = function()
			require("render-markdown").setup({
				file_types = { "markdown", "Avante", "codecompanion" },
				render_modes = { "n", "c", "t", "i" },
			})
		end,
	},
	"yetone/avante.nvim",
	{
		dependencies = {
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			hyhird({ event = "VeryLazy", opts = {} }, "HakonHarnes/img-clip.nvim"),
		},
		build = "make",
		cond = false,
		mod = "avante",
		lazy = false,
	},
	"HakonHarnes/img-clip.nvim",
	{
		opts = {
			default = {
				embed_image_as_base64 = false,
				prompt_for_file_name = false,
				drag_and_drop = { insert_mode = true },
			},
		},
	},
	"stevearc/oil.nvim",
	{
		config = function()
			require("oil").setup({ columns = { "icons", "size" } })
			vim.keymap.set("n", "-", "<cmd>Oil<cr>")
		end,
	},
	"rafamadriz/friendly-snippets",
	{ config = function() end },
	"garymjr/nvim-snippets",
	{ opts = { friendly_snippets = true }, cond = use_cmp },
	"folke/noice.nvim",
	{
		cond = os.getenv("NO_NOICE") == nil or os.getenv("NO_NOICE") == "0",
		config = function()
			require("noice").setup({
				presets = { command_palette = true, long_message_to_split = true },
				views = { mini = { timeout = 5000, focusable = true } },
				lsp = { signature = { enabled = false }, progress = { enabled = false } },
			})
		end,
	},
	"mikesmithgh/kitty-scrollback.nvim",
	{ cond = false },
	"Vigemus/iron.nvim",
	{
		config = function()
			require("iron.core").setup({
				config = {
					scratch_repl = true,
					repl_open_cmd = "vertical botright 80 split",
					repl_definition = {
						sh = { command = { "zsh" } },
						ts = { command = { "bun repl" } },
						python = { command = { "ipython" } },
					},
				},
				keymaps = { visual_send = "<leader>rv", send_line = "<leader>rl" },
			})
		end,
	},
	"JunYang-tes/blink.compat",
	{ lazy = true, opts = {} },
	"folke/neodev.nvim",
	{ opts = {} },
	"saghen/blink.cmp",
	{
		cond = use_blink,
		version = "*",
		opts = {
			keymap = {
				preset = "enter",
				["<CR>"] = { "accept", "fallback" },
				["<C-j>"] = { "select_next", "fallback" },
				["<C-k>"] = { "select_prev", "fallback" },
			},
			completion = {
				list = { selection = { preselect = true, auto_insert = false } },
				accept = { auto_brackets = { enabled = false } },
				trigger = { show_on_trigger_character = true },
				documentation = { auto_show = true },
			},
			signature = { enabled = true },
			cmdline = { keymap = { preset = "inherit" }, completion = { menu = { auto_show = true } } },
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				per_filetype = {
					AvanteInput = { "avante_commands", "avante_files", "avante_mentions" },
					agent_prompt = { "path", "buffer", "AgentsParterFileReference" },
				},
				providers = {
					avante_commands = {
						name = "avante_commands",
						module = "blink.compat.source",
						score_offset = 90,
						opts = {},
					},
					AgentsParterFileReference = {
						name = "AgentsParterFileReference",
						module = "agents-parter.file_reference_source",
					},
					lsp = { min_keyword_length = 0 },
					avante_files = {
						name = "avante_files",
						module = "blink.compat.source",
						score_offset = 100,
						opts = {},
					},
					avante_mentions = {
						name = "avante_mentions",
						module = "blink.compat.source",
						score_offset = 1000,
						opts = {},
					},
				},
			},
		},
		opts_extend = { "sources.default" },
	},
	"JunYang-tes/markdowny.nvim",
	{
		config = function()
			require("markdowny").setup({})
		end,
	},
	"nvim-pack/nvim-spectre",
	{},
	"JunYang-tes/gemini-nvim",
	{
		config = function()
			require("agents-parter").setup({
				window_style = "side",
				side_position = "left",
				agents = {
					{
						name = "Gemini3",
						program = "gemini",
						toggle_keymap = "<F3>",
						params = { "-m", "gemini-3-pro-preview" },
					},
					{
						name = "Gemini",
						program = "gemini",
						toggle_keymap = "<F4>",
						params = { "-m", "gemini-2.5-pro" },
					},
					{
						name = "Gemini3f",
						program = "gemini",
						toggle_keymap = "<F4>",
						params = { "-m", "gemini-3-flash-preview" },
					},
					{
						name = "Deepseek",
						program = "claude",
						envs = {
							ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic",
							ANTHROPIC_API_KEY = os.getenv("deepseek_key"),
							API_TIMEOUT_MS = "600000",
							ANTHROPIC_SMALL_FAST_MODEL = "deepseek-chat",
							ANTHROPIC_MODEL = "deepseek-chat",
						},
					},
					{
						name = "MSQwen",
						program = "claude",
						params = { "--verbose" },
						envs = {
							ANTHROPIC_BASE_URL = "https://api-inference.modelscope.cn/",
							ANTHROPIC_SMALL_FAST_MODEL = "Qwen/Qwen3-Coder-480B-A35B-Instruct",
							ANTHROPIC_MODEL = "Qwen/Qwen3-Coder-480B-A35B-Instruct",
							ANTHROPIC_API_KEY = os.getenv("MODELSCOPE_API_KEY"),
						},
					},
					{
						name = "MSQwen30",
						program = "claude",
						params = { "--verbose" },
						envs = {
							ANTHROPIC_BASE_URL = "https://api-inference.modelscope.cn/",
							ANTHROPIC_SMALL_FAST_MODEL = "Qwen/Qwen3-Coder-30B-A3B-Instruct",
							ANTHROPIC_MODEL = "Qwen/Qwen3-Coder-30B-A3B-Instruct",
							ANTHROPIC_API_KEY = os.getenv("MODELSCOPE_API_KEY"),
						},
					},
					{
						name = "MSGLM",
						program = "claude",
						envs = {
							ANTHROPIC_BASE_URL = "https://api-inference.modelscope.cn/",
							ANTHROPIC_MODEL = "ZhipuAI/GLM-4.7",
							ANTHROPIC_SMALL_FAST_MODEL = "ZhipuAI/GLM-4.7",
							ANTHROPIC_API_KEY = os.getenv("MODELSCOPE_API_KEY"),
						},
					},
					{
						name = "MSGLMV",
						program = "claude",
						envs = {
							ANTHROPIC_BASE_URL = "https://api-inference.modelscope.cn/",
							ANTHROPIC_MODEL = "ZhipuAI/GLM-4.6V",
							ANTHROPIC_SMALL_FAST_MODEL = "ZhipuAI/GLM-4.6V",
							ANTHROPIC_API_KEY = os.getenv("MODELSCOPE_API_KEY"),
						},
					},
					{
						name = "MSDeepseek",
						program = "claude",
						envs = {
							ANTHROPIC_BASE_URL = "https://api-inference.modelscope.cn/",
							ANTHROPIC_MODEL = "deepseek-ai/DeepSeek-V3.2",
							ANTHROPIC_SMALL_FAST_MODEL = "deepseek-ai/DeepSeek-V3.2",
							ANTHROPIC_API_KEY = os.getenv("MODELSCOPE_API_KEY"),
						},
					},
					{
						name = "MSKimi",
						program = "claude",
						envs = {
							ANTHROPIC_BASE_URL = "https://api-inference.modelscope.cn/",
							ANTHROPIC_MODEL = "moonshotai/Kimi-K2.5",
							ANTHROPIC_SMALL_FAST_MODEL = "moonshotai/Kimi-K2.5",
							ANTHROPIC_API_KEY = os.getenv("MODELSCOPE_API_KEY"),
						},
					},
					{
						name = "SCGLM",
						program = "claude",
						envs = {
							ANTHROPIC_BASE_URL = "https://api.siliconflow.cn",
							ANTHROPIC_MODEL = "zai-org/GLM-4.6",
							ANTHROPIC_SMALL_FAST_MODEL = "zai-org/GLM-4.6",
							ANTHROPIC_API_KEY = os.getenv("SILICONFLOW_AI_KEY"),
						},
					},
					{
						name = "APGLM",
						program = "claude",
						envs = {
							ANTHROPIC_BASE_URL = "https://aiping.cn/api/v1/anthropic",
							ANTHROPIC_MODEL = "GLM-4.7",
							ANTHROPIC_SMALL_FAST_MODEL = "GLM-4.7",
							ANTHROPIC_API_KEY = os.getenv("AIPING_KEY"),
						},
					},
					{
						name = "APGLM46v",
						program = "claude",
						envs = {
							ANTHROPIC_BASE_URL = "https://aiping.cn/api/v1/anthropic",
							ANTHROPIC_MODEL = "GLM-4.6V",
							ANTHROPIC_SMALL_FAST_MODEL = "GLM-4.6V",
							ANTHROPIC_API_KEY = os.getenv("AIPING_KEY"),
						},
					},
					{
						name = "AntiClaude",
						program = "claude",
						envs = {
							ANTHROPIC_BASE_URL = "http://127.0.0.1:8045",
							ANTHROPIC_MODEL = "claude-sonnet-4-5",
							ANTHROPIC_SMALL_FAST_MODEL = "gemini-2.5-flash",
							ANTHROPIC_API_KEY = os.getenv("AIPING_KEY"),
						},
					},
					{ name = "Opencode", program = "opencode" },
					{
						name = "CCDeepseek",
						program = "claude",
						envs = {
							ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic",
							ANTHROPIC_MODEL = "deepseek-chat",
							ANTHROPIC_SMALL_FAST_MODEL = "deepseek-chat",
							ANTHROPIC_API_KEY = os.getenv("deepseek_key"),
						},
					},
				},
			})
		end,
	},
	"h-hg/fcitx.nvim",
	{},
	"JunYang-tes/colorful-winsep.nvim",
	{
		config = function()
			require("colorful-winsep").setup({})
		end,
	},
	"dfendr/clipboard-image.nvim",
	{}
)

require("magic.face")
require("magic.project-scripts")
require("magic.bigfile")
require("magic.cmds")
require("magic.hack.mini")

local function set_title()
	local title = "nvimcode " .. vim.fn.getcwd()
	vim.api.nvim_set_option("titlestring", title)
end
set_title()
