(module magic.plugin.avante
  {autoload {nvim aniseed.nvim}})

(let [(ok? avante) (pcall require :avante)]
  (when ok?
    (local config (require :avante.config))
    (local providers (require :avante.providers))
    ; (local openai-provider (require :avante.providers.openai))
    ; (local suggestion-provider (vim.tbl_deep_extend
    ;                              :force
    ;                              openai-provider
    ;                              {:endpoint (os.getenv :ANVATE_OPENAI_HOST)
    ;                               :api_key_name :ANVATE_OPENAI_KEY
    ;                               :model :deepseek-ai/DeepSeek-V2.5
    ;                               :local false}))

    (var current (os.getenv :ANVATE_OPENAI_MODEL))
    (let [openai (require :avante.providers.openai)
          avante (. (require :avante))]
      (tset openai :api_key_name :ANVATE_OPENAI_KEY)
      (avante.setup
        {:provider (os.getenv :ANVATE_PROVIDER)
         ; :auto_suggestions_provider "suggestion-provider"
         ; :behaviour {:auto_suggestions true}
         ; :vendors {: suggestion-provider}
         :openai {:endpoint (os.getenv :ANVATE_OPENAI_HOST)
                  :model (os.getenv :ANVATE_OPENAI_MODEL)
                  :local false}
         :azure {:endpoint (os.getenv :AZURE_HOST)
                 :deployment (os.getenv :AZURE_HOST_DEPOLYMENT)
                 :local false}}))
    (fn switch-model [model]
      (print model)
      (set current model)
      (avante.setup
        {:provider (os.getenv :ANVATE_PROVIDER)
         :openai {:endpoint (os.getenv :ANVATE_OPENAI_HOST)
                  :model (if (= (os.getenv :ANVATE_PROVIDER) :openai) 
                           model
                           (os.getenv :ANVATE_OPENAI_MODEL))
                  :local false}
         :azure {:endpoint (os.getenv :AZURE_HOST)
                 :deployment (os.getenv :AZURE_HOST_DEPOLYMENT)
                 :local false}}))
    (vim.api.nvim_create_user_command
      :ShowModel
      (fn []
        (print current))
      {:desc "Show Model"})
    (vim.api.nvim_create_user_command
      :SwitchModel
      (fn [{: name : args 
            : fargs}]
        (let [(modename _) (string.gsub (. fargs 1) "%(.*%)" "")]
             (switch-model modename)))
      {:desc "Switch Model"
       :complete (fn []
                   ["Qwen/Qwen2.5-72B-Instruct(￥4.13 / M tokens)"
                    "Qwen/Qwen2.5-Coder-7B-Instruct(free)"
                    "deepseek-ai/DeepSeek-V2.5(￥1.33 / M tokens)"
                    "meta-llama/Meta-Llama-3.1-8B-Instruct(free)"
                    "meta-llama/Meta-Llama-3.1-70B-Instruct(￥4.13 / M tokens)"
                    "meta-llama/Meta-Llama-3.1-405B-Instruct(￥21 / M tokens)"])
       :nargs "*"})))
    
      
