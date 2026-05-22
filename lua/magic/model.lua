local proxies = {
	siliconflow = {
		kind = "openai",
		endpoint = "https://api.siliconflow.cn/v1/chat/completions",
		baseUrl = "https://api.siliconflow.cn/v1",
		options = {},
		models = {
			{ "Qwen/Qwen2.5-72B-Instruct", "(￥4.13 / M tokens)" },
			{ "Qwen/Qwen2.5-Coder-7B-Instruct", "(free)" },
			{ "Qwen/Qwen2.5-Coder-32B-Instruct", "(￥1.26 / M tokens)" },
			{ "deepseek-ai/DeepSeek-R1-Distill-Llama-8B", "(free)" },
			{ "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B", "(free)" },
			{ "deepseek-ai/DeepSeek-V2.5", "(￥1.33 / M tokens)" },
			{ "Pro/deepseek-ai/DeepSeek-R1", "(￥4/￥16 M tokens)" },
			{ "deepseek-ai/DeepSeek-R1", "(￥4/￥16 M tokens)" },
			{ "deepseek-ai/DeepSeek-V3", "(￥2/￥8 M tokens)" },
			{ "meta-llama/Meta-Llama-3.1-8B-Instruct", "(free)" },
			{ "meta-llama/Meta-Llama-3.1-70B-Instruct", "(￥4.13 / M tokens)" },
			{ "meta-llama/Meta-Llama-3.1-405B-Instruct", "(￥21 / M tokens)" },
		},
	},
	deepseek = {
		kind = "deepseek",
		compatible = "openai",
		endpoint = "https://api.deepseek.com/v1/chat/completions",
		baseUrl = "https://api.deepseek.com/v1",
		can_reason = { ["deepseek-reasoner"] = true },
		models = { "deepseek-chat", "deepseek-coder", "deepseek-reasoner" },
	},
	aihubmix = {
		kind = "openai",
		endpoint = "https://aihubmix.com/v1/chat/completions",
		baseUrl = "https://aihubmix.com/v1",
		models = {
			{ "claude-3-5-sonnet@20240620", "($4/$20)" },
			{ "claude-3-5-haiku-20241022", "($1.3/$6.5)" },
			"gpt-4o-mini",
		},
	},
	volcengine = {
		kind = "deepseek",
		compatible = "openai",
		endpoint = "https://ark.cn-beijing.volces.com/api/v3/chat/completions",
		baseUrl = "https://ark.cn-beijing.volces.com/api/v3",
		can_reason = { ["deepseek-r1-250120"] = true },
		options = { ["deepseek-r1-250120"] = { tools = false } },
		models = { "deepseek-r1-250120", "deepseek-v3-241226" },
	},
	google = {
		kind = "gemini",
		models = {
			"gemini-2.0-flash",
			"gemini-exp-1206",
			"gemini-2.0-pro-exp-02-05",
			"gemini-2.0-flash-thinking-exp-01-21",
		},
	},
}

local models = {}
for proxy_name, proxy_info in pairs(proxies) do
	for _, model in ipairs(proxy_info.models) do
		if type(model) == "string" then
			table.insert(models, proxy_name .. "/" .. model)
		elseif type(model) == "table" then
			table.insert(models, proxy_name .. "/" .. model[1] .. model[2])
		end
	end
end

local function load_model()
	local file = io.open(os.getenv("HOME") .. "/.config/.model", "r")
	if file then
		local model = file:read("*l")
		print(model)
		file:close()
		return model
	end
end

local current_model = load_model() or "google/gemini-2.0-flash"

local on_change = {}

local function save_model(model)
	if model ~= current_model then
		current_model = model
		for _, f in ipairs(on_change) do
			pcall(f)
		end
		local file = io.open(os.getenv("HOME") .. "/.config/.model", "w")
		if file then
			file:write(model)
			file:close()
		end
	end
end

local function get_models()
	return models
end

local function get_proxies()
	return proxies
end

local function add_on_change(f)
	table.insert(on_change, f)
end

local function get_model()
	return current_model
end

local function model_picker(on_pick)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local conf = require("telescope.config").values
	local picker = pickers.new({}, {
		prompt_title = "Select Model",
		finder = finders.new_table({ results = models }),
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

vim.api.nvim_create_user_command("SwitchModel", function()
	model_picker(save_model)
end, { desc = "Switch Model" })

local prefered_ai_plugin = nil

local function load_prefered_ai_plugin()
	local file = io.open(os.getenv("HOME") .. "/.config/.prefered_ai_plugin", "r")
	if file then
		local plugin = file:read("*l")
		file:close()
		return plugin
	end
	return "avante"
end

local function get_prefered_ai_plugin()
	if prefered_ai_plugin == nil then
		prefered_ai_plugin = load_prefered_ai_plugin()
	end
	return prefered_ai_plugin
end

local function save_prefered_ai_plugin(plugin)
	local file = io.open(os.getenv("HOME") .. "/.config/.prefered_ai_plugin", "w")
	if file then
		file:write(plugin)
		file:close()
		prefered_ai_plugin = plugin
	end
end

return {
	get_models = get_models,
	get_proxies = get_proxies,
	load_model = load_model,
	save_model = save_model,
	get_model = get_model,
	add_on_change = add_on_change,
	model_picker = model_picker,
	get_prefered_ai_plugin = get_prefered_ai_plugin,
	save_prefered_ai_plugin = save_prefered_ai_plugin,
	on_change = on_change,
}
