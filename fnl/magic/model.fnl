(module magic.model
  {autoload {nvim aniseed.nvim
             a aniseed.core}})

(local proxies 
  {:siliconflow  {:kind :openai
                  :endpoint "https://api.siliconflow.cn/v1"
                  :models ["Qwen/Qwen2.5-72B-Instruct(￥4.13 / M tokens)"
                           "Qwen/Qwen2.5-Coder-7B-Instruct(free)"
                           "Qwen/Qwen2.5-Coder-32B-Instruct(￥1.26 / M tokens)"
                           "deepseek-ai/DeepSeek-V2.5(￥1.33 / M tokens)"
                           "deepseek-ai/DeepSeek-R1(￥4/￥16 M tokens)"
                           "deepseek-ai/DeepSeek-V3(￥2/￥8 M tokens)"
                           "meta-llama/Meta-Llama-3.1-8B-Instruct(free)"
                           "meta-llama/Meta-Llama-3.1-70B-Instruct(￥4.13 / M tokens)"
                           "meta-llama/Meta-Llama-3.1-405B-Instruct(￥21 / M tokens)"]}
   :deepseek     {:kind :openai
                  :endpoint "https://api.deepseek.com/v1"
                  :models ["deepseek-chat" "deepseek-coder" "deepseek-reasoner"]}
   :ollama       {:kind :openai
                  :endpoint "http://127.0.0.1:11434/v1"
                  :local true
                  :models ["deepseek-r1:1.5b"
                           "deepseek-r1"]}
                  
   :aihubmix     {:kind :openai
                  :endpoint "https://aihubmix.com/v1"
                  :models ["claude-3-5-sonnet@20240620($4/$20)"
                           "claude-3-5-haiku-20241022($1.3/$6.5)"
                           "gpt-4o-mini"]}
   :google       {:kind :gemini
                  :models [:gemini-2.0-flash
                           :gemini-exp-1206
                           :gemini-2.0-flash-thinking-exp-01-21]}})
    
(local models
  (let [all-models []]
    (each [proxy-name proxy-info (pairs proxies)]
      (each [_ model (ipairs proxy-info.models)]
        (table.insert all-models (.. proxy-name "/" model))))
    all-models))

(defn load_model []
  (let [file (io.open (.. (os.getenv "HOME") "/.config/.avante_model") "r")]
    (if file
      (do
        (var model (file:read "*l"))
        (print model)
        (file:close)
        model))))

(var current_model (or
                    (load_model)
                    (os.getenv :ANVATE_OPENAI_MODEL)))

(local on_change [])

(defn save_model [model]
  (when (not= model current_model)
    (set current_model model)
    (each [_ f (ipairs on_change)]
      (pcall f))

    (let [file (io.open (.. (os.getenv "HOME") "/.config/.avante_model") "w")]
      (if file
        (do
          (file:write model)
          (file:close))))))

(defn get-models []
  models)

(defn get-proxies []
  proxies)

(defn parse-model [model]
  (let [
        (start) (string.find model "/")
        proxy-name (string.sub model 1 (- start 1))
        model-name (string.sub model (+ start 1))]
    [proxy-name (string.gsub model-name "%(.*%)" "")]))

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
