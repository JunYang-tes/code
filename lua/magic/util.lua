local function expand(path)
	return vim.fn.expand(path)
end

local function glob(path)
	return vim.fn.glob(path, true, true, true)
end

local function exists(path)
	return vim.fn.filereadable(path) == 1
end

local function lua_file(path)
	vim.cmd("luafile " .. path)
end

local config_path = vim.fn.stdpath("config")

local function some(list, predict)
	for _, item in ipairs(list) do
		if predict(item) then
			return true
		end
	end
	return false
end

local function nnoremap(from, to, opts)
	local map_opts = { noremap = true }
	to = ":" .. to .. "<cr>"
	if opts and opts["local?"] then
		vim.api.nvim_buf_set_keymap(0, "n", from, to, map_opts)
	else
		vim.api.nvim_set_keymap("n", from, to, map_opts)
	end
end

local function noremap(from, to, opts)
	local map_opts = { noremap = true }
	if opts and opts["local?"] then
		vim.api.nvim_buf_set_keymap(0, "n", from, to, map_opts)
	else
		vim.api.nvim_set_keymap("n", from, to, map_opts)
	end
end

local function lnnoremap(from, to)
	nnoremap("<leader>" .. from, to)
end

local function is_a_big_file(buf, max_size)
	local fname = vim.api.nvim_buf_get_name(buf)
	max_size = max_size or 500
	local size = vim.fn.getfsize(fname) / 1024
	return size > max_size
end

local function has_long_line(bufnr, max_length)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	max_length = max_length or 100000
	return some(lines, function(line)
		return #line > max_length
	end)
end

local function monkey_patch(tbl, fn_name, f)
	local original = tbl[fn_name]
	tbl[fn_name] = function(...)
		return f(tbl, original, ...)
	end
end

local function map_cmd(mode, key, cmd)
	vim.keymap.set(mode, key, "<cmd>" .. cmd .. "<cr>")
end

local function map_plug(mode, key, cmd)
	vim.keymap.set(mode, key, "<Plug>(" .. cmd .. ")")
end

local function first_key(tbl)
	for k in pairs(tbl) do
		return k
	end
end

local function pick(list, title, on_pick)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local conf = require("telescope.config").values
	local picker = pickers.new({}, {
		prompt_title = title,
		finder = finders.new_table({ results = list }),
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, map)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if selection then
					on_pick(selection.value)
				end
			end)
			return true
		end,
	})
	picker:find()
end

local function read_prompt()
	local file_path = vim.g.magic_root .. "/fnl/magic/plugin/companion.txt"
	local file = io.open(file_path, "r")
	if file then
		local content = file:read("*a")
		file:close()
		return content
	end
	return nil
end

local function get_path(relative)
	local root = os.getenv("NCODE_CONFIG") or config_path
	return root .. "/" .. relative
end

return {
	expand = expand,
	glob = glob,
	exists = exists,
	lua_file = lua_file,
	config_path = config_path,
	some = some,
	nnoremap = nnoremap,
	noremap = noremap,
	lnnoremap = lnnoremap,
	is_a_big_file = is_a_big_file,
	has_long_line = has_long_line,
	monkey_patch = monkey_patch,
	map_cmd = map_cmd,
	map_plug = map_plug,
	first_key = first_key,
	pick = pick,
	read_prompt = read_prompt,
	get_path = get_path,
}
