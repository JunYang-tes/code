(module magic.model
  {autoload {nvim aniseed.nvim
             a aniseed.core}})

(local proxies 
  {:siliconflow  {:kind :openai
                  :endpoint "https://api.siliconflow.cn/v1/chat/completions"
                  :baseUrl "https://api.siliconflow.cn/v1"
                  :options {}
                  :models [["Qwen/Qwen2.5-72B-Instruct" "(￥4.13 / M tokens)"]
                           ["Qwen/Qwen2.5-Coder-7B-Instruct" "(free)"]
                           ["Qwen/Qwen2.5-Coder-32B-Instruct" "(￥1.26 / M tokens)"]
                           ["deepseek-ai/DeepSeek-R1-Distill-Llama-8B" "(free)"]
                           ["deepseek-ai/DeepSeek-R1-Distill-Qwen-7B" "(free)"]
                           ["deepseek-ai/DeepSeek-V2.5" "(￥1.33 / M tokens)"]
                           ["Pro/deepseek-ai/DeepSeek-R1"  "(￥4/￥16 M tokens)"]
                           ["deepseek-ai/DeepSeek-R1" "(￥4/￥16 M tokens)"]
                           ["deepseek-ai/DeepSeek-V3" "(￥2/￥8 M tokens)"]
                           ["meta-llama/Meta-Llama-3.1-8B-Instruct" "(free)"]
                           ["meta-llama/Meta-Llama-3.1-70B-Instruct" "(￥4.13 / M tokens)"]
                           ["meta-llama/Meta-Llama-3.1-405B-Instruct" "(￥21 / M tokens)"]]}
   :deepseek     {:kind :deepseek
                  :compatible :openai
                  :endpoint "https://api.deepseek.com/v1/chat/completions"
                  :baseUrl "https://api.deepseek.com/v1"
                  :can_reason {:deepseek-r1 true}
                  :models ["deepseek-chat" "deepseek-coder" "deepseek-reasoner"]}
                  
   :aihubmix     {:kind :openai
                  :endpoint "https://aihubmix.com/v1/chat/completions"
                  :baseUrl "https://aihubmix.com/v1"
                  :models [["claude-3-5-sonnet@20240620" "($4/$20)"]
                           ["claude-3-5-haiku-20241022" "($1.3/$6.5)"]
                           "gpt-4o-mini"]}
   :volcengine   {:kind :deepseek
                  :compatible :openai
                  :endpoint "https://ark.cn-beijing.volces.com/api/v3/chat/completions"
                  :baseUrl "https://ark.cn-beijing.volces.com/api/v3"
                  :can_reason {:deepseek-r1-250120 true}
                  :options {:deepseek-r1-250120 {:tools false}}
                  :models [:deepseek-r1-250120 :deepseek-v3-241226]}
   :google       {:kind :gemini
                  :models [:gemini-2.0-flash
                           :gemini-exp-1206
                           :gemini-2.0-pro-exp-02-05
                           :gemini-2.0-flash-thinking-exp-01-21]}})
    
(local models
  (let [all-models []]
    (each [proxy-name proxy-info (pairs proxies)]
      (each [_ model (ipairs proxy-info.models)]
        (match (type model)
          :string (table.insert all-models (.. proxy-name "/" model))
          :table  (table.insert all-models (.. proxy-name "/" (. model 1) (. model 2))))))
        
    all-models))

(defn load_model []
  (let [file (io.open (.. (os.getenv "HOME") "/.config/.model") "r")]
    (if file
      (do
        (var model (file:read "*l"))
        (print model)
        (file:close)
        model))))

(var current_model (or
                    (load_model)
                    "google/gemini-2.0-flash"))

(local on_change [])

(defn save_model [model]
  (when (not= model current_model)
    (set current_model model)
    (each [_ f (ipairs on_change)]
      (pcall f))

    (let [file (io.open (.. (os.getenv "HOME") "/.config/.model") "w")]
      (if file
        (do
          (file:write model)
          (file:close))))))

(defn get-models []
  models)

(defn get-proxies []
  proxies)

(defn add_on_change [f] (table.insert on_change f))

(defn get_model [] current_model)

(defn model-picker [on-pick]
     (let [pickers (require :telescope.pickers)
           finders (require :telescope.finders)
           actions (require :telescope.actions)
           action-state (require :telescope.actions.state)
           conf (. (require :telescope.config) :values)
           f (pickers.new
              {}
              {:prompt_title "Select Model"
               :finder (finders.new_table {:results models})
               :sorter (conf.generic_sorter {})
               :attach_mappings
               (fn [prompt_bufnr map]
                 (actions.select_default:replace
                  (fn []
                    (actions.close prompt_bufnr)
                    (let [selection (action-state.get_selected_entry)]
                      (when selection
                        (on-pick selection.value)))))
                 true)})]
       (f:find)))

(vim.api.nvim_create_user_command
 :SwitchModel
 #(model-picker save_model)
 {:desc "Switch Model"})

(var prefered_ai_plugin :nil)
(defn load-prefered_ai-plugin []
  (let [file (io.open (.. (os.getenv "HOME") "/.config/.prefered_ai_plugin") "r")]
    (if file
      (do
        (var plugin (file:read "*l"))
        (file:close)
        plugin)
      "avante")))
(defn get-prefered-ai-plugin []
  (if (not= nil prefered_ai_plugin)
    (set prefered_ai_plugin (load-prefered_ai-plugin)))
  prefered_ai_plugin)
(defn save-prefered-ai-plugin [plugin]
  (let [file (io.open (.. (os.getenv "HOME") "/.config/.prefered_ai_plugin") "w")]
    (if file
      (do
        (file:write plugin)
        (file:close)
        (set prefered_ai_plugin plugin)))))
