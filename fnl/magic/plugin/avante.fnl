(module magic.plugin.avante
  {autoload {nvim aniseed.nvim
             telescope telescope.pickers}})

(local proxies 
  {:siliconflow  {:kind :openai
                  :endpoint "https://api.siliconflow.cn/v1"
                  :models ["Qwen/Qwen2.5-72B-Instruct(￥4.13 / M tokens)"
                           "Qwen/Qwen2.5-Coder-7B-Instruct(free)"
                           "Qwen/Qwen2.5-Coder-32B-Instruct(￥1.26 / M tokens)"
                           "deepseek-ai/DeepSeek-V2.5(￥1.33 / M tokens)"
                           "meta-llama/Meta-Llama-3.1-8B-Instruct(free)"
                           "meta-llama/Meta-Llama-3.1-70B-Instruct(￥4.13 / M tokens)"
                           "meta-llama/Meta-Llama-3.1-405B-Instruct(￥21 / M tokens)"]}
   :deepseek     {:kind :openai
                  :endpoint "https://api.deepseek.com/v1"
                  :models ["deepseek-chat"]}
   :aihubmix     {:kind :openai
                  :endpoint "https://aihubmix.com/v1"
                  :models ["claude-3-5-sonnet@20240620($4/$20)"
                           "claude-3-5-haiku-20241022($1.3/$6.5)"
                           "gpt-4o-mini"]}
   :google       {:kind :gemini
                  :models [:gemini-2.0-flash-exp
                           :gemini-2.0-flash-thinking-exp-1219]}})
    
(local models
  (let [all-models []]
    (each [proxy-name proxy-info (pairs proxies)]
      (each [_ model (ipairs proxy-info.models)]
        (table.insert all-models (.. proxy-name "/" model))))
    all-models))

(fn parse-model [model]
  (let [
        (start) (string.find model "/")
        proxy-name (string.sub model 1 (- start 1))
        model-name (string.sub model (+ start 1))]
    [proxy-name (string.gsub model-name "%(.*%)" "")]))

(fn get-provider [model]
  (let [[proxy-name model-name] (parse-model model)
        proxy (. proxies proxy-name)]
    (if (not= proxy nil)
      (let [
            setup-param {:provider proxy.kind
                         :debug true}]
         (tset setup-param
               proxy.kind
               {:endpoint proxy.endpoint
                :model model-name
                :api_key_name (.. :avante_key_ proxy-name)})
         setup-param)
      (do 
        (print "Not Found" model)
        {}))))

        

(let [(ok? avante) (pcall require :avante)]
  (when ok?
    (local config (require :avante.config))
    (local providers (require :avante.providers))
    ; (local suggestion-provider (vim.tbl_deep_extend
    ;                              :force
    ;                              openai-provider
    ;                              {:endpoint (os.getenv :ANVATE_OPENAI_HOST)
    ;                               :api_key_name :ANVATE_OPENAI_KEY
    ;                               :model :deepseek-ai/DeepSeek-V2.5
    ;                               :local false}))

    (var current (os.getenv :ANVATE_OPENAI_MODEL))
    (avante.setup (get-provider current))
    (fn switch-model [model]
      (set current model)
      (let [params (get-provider model)
            providers (require :avante.providers)] 
        (tset providers 
              params.provider
              (vim.tbl_extend :force
                              (. providers params.provider)
                              (. params params.provider)))
        (print (vim.inspect providers))
        (avante.setup (get-provider model))))
        ;(providers.refresh params.provider)))
    (fn model-picker []
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
                         (switch-model selection.value)))))
                  true)})]
        (f:find)))
    (vim.api.nvim_create_user_command
      :SwitchModel
      (fn []
        (model-picker))
      {:desc "Switch Model"})
    (vim.api.nvim_create_user_command
      :ShowModel
      (fn []
        (print current))
      {:desc "Show Model"})))
