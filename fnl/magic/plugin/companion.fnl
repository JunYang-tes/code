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
  (local adapters_config {:opts {:show_defaults false}})
  (each [proxy-name proxy (pairs (model.get-proxies))]
    (let [kind (. proxy :kind)
          compatible (. proxy :compatible)
          adapter (or (require-adapter kind)
                      (require-adapter compatible))
          can_reason (or proxy.can_reason {})
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
                
                adapter (require (.. :codecompanion.adapters "." kind))
                custom-adapter (adapters.extend 
                                  kind
                                  {:env {:api_key (os.getenv (.. :avante_key_ proxy-name))}
                                   :url (or endpoint
                                            adapter.url)
                                   : name
                                   :formatted_name name
                                   :opts {:can_reason (. can_reason model)}
                                   :schema {:model {:default model}}})] 
                 
            (tset custom-adapter.schema.model :choices [model])
            (tset adapters_config name custom-adapter))))))
                  
            
  (print (. (require :vectorcode.integrations)
            :codecompanion.chat.make_slash_command))
  (let [adapter (if (not= nil (. adapters_config model-name))
                    model-name
                    (first adapters_config))]
    {:adapters adapters_config
     :strategies {:chat {:adapter adapter
                         :slash_commands {:codebase ((. (require :vectorcode.integrations)
                                                        :codecompanion :chat :make_slash_command))}}
                  :inline {:adapter adapter}
                  :cmd {:adapter adapter}
                  :agent {:adapter adapter}}
     :opts {:log_level :ERROR}}))

(let [(ok? companion) (pcall #(require :codecompanion))]
  (when ok?
    (let [deepseek (require :codecompanion.adapters.deepseek)
          chat_output (. deepseek :handlers :chat_output)]
      (tset deepseek :handlers :chat_output
            (fn [...]
              (let [out (chat_output ...)]
                (if (and (not= nil out)
                         (= (. out :status)
                            :success)
                         (not= (. out :output :reasoning) nil)
                         (not= (. out :output :reasoning) "")
                         (= (. out :output :content) ""))
                  (tset out :output :content nil))
                out))))
      
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
    (model.add_on_change
      #(let [m (model.get_model)]
         (companion.setup (get-setup-param m))))))
