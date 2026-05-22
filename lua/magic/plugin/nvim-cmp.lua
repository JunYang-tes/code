vim.o.completeopt = "menu,preview,noinsert"
vim.o.pumheight = 10

local icons = {
	Text = "",
	Method = "",
	Function = "󰊕",
	Constructor = "",
	Field = "󰇽",
	Variable = "",
	Class = "",
	Interface = "",
	Module = "",
	Property = "󰜢",
	Unit = "",
	Value = "󰎠",
	Enum = "",
	Keyword = "󰌋",
	Snippet = "",
	Color = "󰏘",
	File = "󰈙",
	Reference = "",
	Folder = "󰉋",
	EnumMember = "",
	Constant = "󰏿",
	Struct = "",
	Event = "",
	Operator = "󰆕",
	TypeParameter = "",
}

local function format(entry, vim_item)
	vim_item.kind = string.format("%s %s", icons[vim_item.kind], vim_item.kind)
	local max_length = 40
	local abbr = vim_item.abbr
	if #abbr > max_length then
		vim_item.abbr = string.sub(vim_item.abbr, 1, 40) .. "..."
	end
	return vim_item
end

local ok, cmp = pcall(function()
	return require("cmp")
end)
if ok then
	cmp.visible = function()
		return cmp.core.view:visible() or vim.fn.pumvisible() == 1
	end

	cmp.setup.global({
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "snippets" },
			{
				name = "buffer",
				option = {
					get_bufnrs = function()
						local bufs = vim.api.nvim_list_bufs()
						local function big_file(buf)
							local byte = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
							return byte > 1024 * 1024
						end
						local function should_ignore(filename)
							local ignores = { "package-lock.json", "pnpm-lock.yaml" }
							for _, ignore in ipairs(ignores) do
								if string.find(filename, ignore, 1, true) ~= nil then
									return true
								end
							end
							return false
						end
						local result = {}
						for _, bufnum in ipairs(bufs) do
							local filename = vim.api.nvim_buf_get_name(bufnum)
							if not should_ignore(filename) and not big_file(bufnum) then
								table.insert(result, bufnum)
							end
						end
						return result
					end,
				},
			},
			{ name = "path" },
		}),
		window = { completion = { max_height = 300 } },
		formatting = { format = format },
		completion = { completeopt = "menu,menuone,preview,noinsert" },
		mapping = cmp.mapping.preset.insert({
			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<down>"] = cmp.mapping(function(fallback)
				if vim.snippet.active({ filter = { jump_dir = 1 } }) then
					vim.snippet.jump(1)
				elseif cmp.visible() then
					cmp.select_next_item()
				else
					fallback()
				end
			end, { "i", "s" }),
			["<D-space>"] = cmp.mapping.complete({ select = true }),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm({ select = true }),
		}),
	})
end
