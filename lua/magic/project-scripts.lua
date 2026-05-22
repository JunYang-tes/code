local function file_exists(file)
	local stat, _ = vim.loop.fs_stat(file)
	return stat ~= nil
end

local function git_root()
	local cwd = vim.fn.getcwd()
	local function find(path)
		local p = path .. "/.git"
		if file_exists(p) then
			return p
		end
		if path == "/" then
			return nil
		end
		return find(vim.fn.fnamemodify(path, ":h"))
	end
	return find(cwd)
end

local search_path = {}
do
	local dotnvim = vim.fn.getcwd() .. "/.nvim"
	local git = git_root()
	if git then
		search_path = { dotnvim, git .. "/.nvim" }
	else
		search_path = { dotnvim }
	end
end

for _, v in ipairs(search_path) do
	local ok, err = pcall(function()
		local path = v .. "/init.lua"
		if file_exists(path) then
			dofile(path)
		end
		local vim_path = v .. "/init.vim"
		if file_exists(vim_path) then
			vim.cmd("source " .. vim_path)
		end
	end)
	if err then
		print("error", err)
	end
end
