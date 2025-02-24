(module magic.plugin.companion
  {autoload {nvim aniseed.nvim
             util magic.util
             model magic.model}})

(fn require-adapter [kind]
  (let [(ok adapter) (pcall require (.. :codecompanion.adapters "." kind))]
    (if ok
      adapter
      nil)))
      
   
(fn first [tbl]
  (each [k (pairs tbl)]
    (lua "return k")))

(fn get-setup-param [model-name]
  (local adapters (require :codecompanion.adapters))
  (local adapters_config {})
  (each [proxy-name proxy (pairs (model.get-proxies))]
    (let [kind (. proxy :kind)
          compatible (. proxy :compatible)
          adapter (or (require-adapter kind)
                      (require-adapter compatible))
          endpoint_ (?. proxy :endpoint)
          endpoint (if (= kind :openai)
                       (.. endpoint_ "/chat/completions")
                       endpoint_)]
      (when adapter
        (each [_ model (ipairs proxy.models)]
          (let [[model price] (if (= (type model) :string)
                                  [model ""]
                                  model)
                name (.. proxy-name "/" model price)
                kind_? (?. proxy :kind)
                
                adapter (require (.. :codecompanion.adapters "." kind))] 
            (tset adapters_config name
                  (adapters.extend 
                    kind
                    {:env {:api_key (os.getenv (.. :avante_key_ proxy-name))}
                     :url (or endpoint
                              adapter.url)
                     : name
                     :formatted_name name
                     :schema {:model {:default model :choices [model]}}})))))))
  (let [adapter (if (not= nil (. adapters_config model-name))
                    model-name
                    (first adapters_config))]
    {:adapters adapters_config
     :strategies {:chat {:adapter adapter}
                  :inline {:adapter adapter}
                  :cmd {:adapter adapter}
                  :agent {:adapter adapter}}
     :opts {:log_level :DEBUG}}))

(let [(ok? companion) (pcall #(require :codecompanion))]
  (when ok?
    (let [model-name (model.get_model)
          param (get-setup-param (model.get_model))]
      (companion.setup param)
      (if (not= (. param :strategies :chat :adapter)
                model-name)
        (do
          (print (.. :No " " model-name))
          (model.save_model param.strategies.chat.adapter))))
                
    (vim.api.nvim_create_user_command
      :PreferCompanion
      #(model.save-prefered-ai-plugin :companion)
      {:desc "Prefer CodeCompanion"})
    (vim.cmd :cab cc CodeCompanion)
    (vim.api.nvim_create_user_command
      :SwitchModel
      (fn []
        (model.model-picker (fn [m]
                              (model.save_model m)
                              (companion.setup (get-setup-param m)))))
      {:desc "Switch Model"})))
