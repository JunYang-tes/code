(module magic.plugin.companion
  {autoload {nvim aniseed.nvim
             util magic.util
             model magic.model}})

(fn get-setup-param [model-name]
  (let [[proxy-name model-name] (model.parse-model model-name)
        proxy (. (model.get-proxies) proxy-name)
        adapters (require :codecompanion.adapters)
        kind_ (?. proxy :kind)
        kind (if (= proxy deepseek)
               :deepseek
               kind_)
        adapter (require (.. :codecompanion.adapters "." kind))
        endpoint_ (?. proxy :endpoint)
        endpoint (if (= kind :openai)
                   (.. endpoint_ "/chat/completions"))]
    (if (and (not= nil kind))
      {:adapters {kind (adapters.extend 
                         kind
                         {:env {:api_key (os.getenv (.. :avante_key_ proxy-name))}
                          :url (or endpoint
                                   adapter.url)
                          :schema {:model {:default model-name}}})}
       :strategies {:chat {:adapter kind}
                    :inline {:adapter kind}
                    :cmd {:adapter kind}
                    :agent {:adapter kind}}
       :opts {:log_level :DEBUG}})))

(let [(ok? companion) (pcall #(require :codecompanion))]
  (when ok?
    (companion.setup
      (get-setup-param (model.get_model)))
    (util.map-cmd :n
                  :<leader>ac "CodeCompanionChat Toggle")
    (util.map-cmd :v
                  :<leader>aa "CodeCompanionChat Add")
    (util.map-cmd [:v :n]
                  :<leader>ae "CodeCompanion /buffer")
    (util.map-cmd [:v :n]
                  :<C-a> "CodeCompanionActions") 
    (vim.api.nvim_create_user_command
      :SwitchModel
      (fn []
        (model.model-picker (fn [m]
                              (model.save_model m)
                              (companion.setup (get-setup-param m)))))
      {:desc "Switch Model"})))
