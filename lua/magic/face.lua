local icons = {
	DiagnosticSignError = "",
	DiagnosticSignWarn = "",
	DiagnosticSignHint = "",
	DiagnosticSignInfor = "",
}
for name, icon in pairs(icons) do
	vim.fn.sign_define(name, { text = icon, texthl = name, numhl = name })
end

vim.o.background = "light"
pcall(function()
	vim.cmd("colorscheme catppuccin")
end)

local function get_hlgroup(name, fallback)
	local ok, hl = pcall(function()
		if vim.fn.hlexists(name) == 1 then
			if vim.api.nvim_get_hl then
				local hl_obj = vim.api.nvim_get_hl(0, { name = name, link = false })
				return { fg = hl_obj.fg or "None", bg = hl_obj.bg or hl_obj.background }
			else
				local hl_obj = vim.api.nvim_get_hl_by_name(name, vim.o.termguicolors)
				return { fg = hl_obj.foreground or "None", bg = hl_obj.background }
			end
		end
		return fallback or {}
	end)
	if ok then
		return hl
	end
	return fallback or {}
end

local function highlights(tbl)
	for group, spec in pairs(tbl) do
		vim.api.nvim_set_hl(0, group, spec)
	end
end

local normal = get_hlgroup("Normal")
local main = get_hlgroup("BufferVisible")
local fg = normal.fg
local bg = normal.bg
local bg_alt = get_hlgroup("Visual").bg
local str_fg = get_hlgroup("String").fg
local prompt = get_hlgroup("lualine_a_command")

highlights({
	TelescopeNormal = { bg = bg },
	TelescopePreviewBorder = { fg = main.bg, bg = main.bg },
	TelescopePreviewNormal = { bg = main.bg },
	TelescopePreviewTitle = { fg = bg, bg = str_fg },
	TelescopePromptBorder = { fg = bg_alt, bg = bg_alt },
	TelescopePromptNormal = { fg = fg, bg = bg_alt },
	TelescopePromptTitle = { fg = bg, bg = prompt.bg },
	TelescopeResultsBorder = { fg = main.bg, bg = main.bg },
	TelescopeResultsNormal = { bg = main.bg },
	TelescopeResultsTitle = { fg = main.bg, bg = main.bg },
	SagaNormal = { link = "TelescopePromptNormal" },
	SagaTitle = { link = "TelescopePromptTitle" },
	SagaBorderTitle = { link = "TelescopePromptTitle" },
	SagaBorder = { link = "TelescopePromptBorder" },
	RenameNormal = { link = "TelescopePromptNormal" },
	ActionPreviewTitle = { link = "TelescopePreviewTitle" },
})
