local lazy = require("lazy")

local function safe_require_plugin_config(name)
	if name then
		local ok, val_or_err = pcall(require, "magic.plugin." .. name)
		if not ok then
			print(string.format("Plugin (%s) config error: (%s)", name, val_or_err))
		end
	end
end

local function req(name)
	return "require('magic.plugin." .. name .. "')"
end

local function use(...)
	local pkgs = { ... }
	local plugins = {}
	for i = 1, #pkgs, 2 do
		local name = pkgs[i]
		local opts = pkgs[i + 1]
		opts.dependencies = opts.dependencies or opts.requires
		opts.build = opts.run or opts.build
		opts[1] = name
		if opts.mod then
			local mod_name = opts.mod
			opts.config = function()
				safe_require_plugin_config(mod_name)
			end
		end
		table.insert(plugins, opts)
	end
	lazy.setup(plugins, { dev = { path = "/home/yj/github" } })
end

return { req = req, use = use }
