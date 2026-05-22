local util = require("magic.util")
local model_fn = require("magic.model")

local function is_supported(kind)
	local ok = pcall(require, "avante.providers." .. kind)
	return ok
end

local function get_setup_param(model)
	local vendors = {}
	for proxy_name, proxy in pairs(model_fn.get_proxies()) do
		local kind = proxy.kind
		local options = proxy.options or {}
		local compatible = proxy.compatible
		for _, model_entry in ipairs(proxy.models) do
			local model_name, price
			if type(model_entry) == "string" then
				model_name = model_entry
				price = ""
			else
				model_name = model_entry[1]
				price = model_entry[2]
			end
			local name = proxy_name .. "/" .. model_name .. price
			vendors[name] = {
				__inherited_from = is_supported(kind) and kind or compatible,
				endpoint = proxy.baseUrl,
				disable_tools = not (options[model_name] and options[model_name].tools),
				api_key_name = "avante_key_" .. proxy_name,
				model = model_name,
			}
		end
	end
	local provider
	if vendors[model] ~= nil then
		provider = model
	else
		provider = util.first_key(vendors)
	end
	return {
		provider = provider,
		behaviour = { support_paste_from_clipboard = true },
		debug = true,
		vendors = vendors,
	}
end

local ok, avante = pcall(require, "avante")
if ok then
	local gemini = require("avante.providers.gemini")
	gemini.parse_response_without_stream = function(data, _, opts) end

	local model_name = model_fn.get_model()
	local param = get_setup_param(model_fn.get_model())
	avante.setup(param)
	if param.provider ~= model_name then
		print("No " .. model_name)
		model_fn.save_model(param.provider)
	end

	local function switch_model(model)
		model_fn.save_model(model)
		avante.setup(get_setup_param(model))
	end

	local function model_picker()
		model_fn.model_picker(switch_model)
	end

	vim.api.nvim_create_user_command("PreferAvante", function()
		model_fn.save_prefered_ai_plugin("avante")
	end, { desc = "Prefer Avante" })

	model_fn.add_on_change(function()
		local m = model_fn.get_model()
		vim.cmd("AvanteSwitchProvider " .. m)
	end)
end
