local function not_a(ft)
	return function(info)
		local buf = vim.bo[info.buf]
		return buf.filetype ~= ft
	end
end

local function not_one_of(fts)
	return function(info)
		local buf = vim.bo[info.buf]
		local count = 0
		for _, ft in ipairs(fts) do
			if ft == buf.filetype then
				count = count + 1
			end
		end
		return count == 0
	end
end

local function not_read_only(info)
	local buf = vim.bo[info.buf]
	return buf.modifiable
end

pcall(function()
	local statuscol = require("statuscol")
	local builtin = require("statuscol.builtin")
	local not_fn_bufs = not_one_of({ "Outline", "NvimTree", "Trouble" })
	statuscol.setup({
		relculright = true,
		setopt = true,
		segments = {
			{
				sign = { namespace = { "diagnostic/signs" }, colwidth = 1 },
				condition = { not_fn_bufs },
				click = "v:lua.ScSa",
			},
			{
				sign = { namespace = { "gitsigns" }, name = { ".*" }, colwidth = 1, wrap = true },
				click = "v:lua.ScSa",
			},
			{
				text = { builtin.foldfunc },
				click = "v:lua.ScFa",
				condition = { not_fn_bufs },
			},
			{
				text = { builtin.lnumfunc },
				condition = { not_fn_bufs },
				click = "v:lua.ScLa",
			},
			{
				text = { "┃" },
				condition = { not_fn_bufs },
			},
			{
				sign = { name = { ".*" }, auto = false },
				click = "v:lua.ScSa",
			},
		},
	})
end)
