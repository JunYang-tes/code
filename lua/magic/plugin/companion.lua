local util = require("magic.util")
local model = require("magic.model")

local function require_adapter(kind)
	local ok, adapter = pcall(require, "codecompanion.adapters." .. kind)
	if ok then
		return adapter
	end
	return nil
end

local function first(tbl)
	for k in pairs(tbl) do
		return k
	end
end

local function get_setup_param(model_name)
	local adapters = require("codecompanion.adapters")
	local adapters_config = { opts = { show_defaults = false } }
	for proxy_name, proxy in pairs(model.get_proxies()) do
		local kind = proxy.kind
		local compatible = proxy.compatible
		local adapter = require_adapter(kind) or require_adapter(compatible)
		local can_reason = proxy.can_reason or {}
		local endpoint_ = proxy.endpoint
		local endpoint
		if kind == "openai" then
			endpoint = endpoint_ .. "/chat/completions"
		else
			endpoint = endpoint_
		end
		if adapter then
			for _, model_entry in ipairs(proxy.models) do
				local model_local, price
				if type(model_entry) == "string" then
					model_local = model_entry
					price = ""
				else
					model_local = model_entry[1]
					price = model_entry[2]
				end
				local name = proxy_name .. "/" .. model_local .. price
				local kind_ = proxy.kind
				local adapter_mod = require("codecompanion.adapters." .. kind)
				local custom_adapter = adapters.extend(kind, {
					env = { api_key = os.getenv("avante_key_" .. proxy_name) },
					url = endpoint or adapter_mod.url,
					name = name,
					formatted_name = name,
					opts = { can_reason = can_reason[model_local] },
					schema = { model = { default = model_local } },
				})
				custom_adapter.schema.model.choices = { model_local }
				adapters_config[name] = custom_adapter
			end
		end
	end

	local adapter
	if adapters_config[model_name] ~= nil then
		adapter = model_name
	else
		adapter = first(adapters_config)
	end
	return {
		adapters = adapters_config,
		strategies = {
			chat = {
				adapter = adapter,
				tools = {
					mcp = {
						callback = function()
							return require("mcphub.extensions.codecompanion")
						end,
					},
					description = "Call tools and resources from the MCP Servers",
					opts = { requires_approval = true },
				},
			},
			inline = { adapter = adapter },
			cmd = { adapter = adapter },
			agent = { adapter = adapter },
		},
		opts = {
			log_level = "DEBUG",
			system_prompt = function()
				return util.read_prompt()
			end,
		},
	}
end

local ok, companion = pcall(function()
	return require("codecompanion")
end)
if ok then
	local deepseek = require("codecompanion.adapters.deepseek")
	local chat_output = deepseek.handlers.chat_output
	deepseek.handlers.chat_output = function(...)
		local out = chat_output(...)
		if
			out ~= nil
			and out.status == "success"
			and out.output.reasoning ~= nil
			and out.output.reasoning ~= ""
			and out.output.content == ""
		then
			out.output.content = nil
		end
		return out
	end

	local model_name = model.get_model()
	local param = get_setup_param(model.get_model())
	companion.setup(param)
	if param.strategies.chat.adapter ~= model_name then
		print("No " .. model_name)
		model.save_model(param.strategies.chat.adapter)
	end

	vim.api.nvim_create_user_command("PreferCompanion", function()
		model.save_prefered_ai_plugin("companion")
	end, { desc = "Prefer CodeCompanion" })

	model.add_on_change(function()
		local m = model.get_model()
		companion.setup(get_setup_param(m))
	end)
end
