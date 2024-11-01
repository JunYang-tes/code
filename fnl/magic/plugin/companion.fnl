(module magic.plugin.companion
  {autoload {nvim aniseed.nvim}})

(let [(ok? companion) (pcall #(require :codecompanion))]
  (when ok?
    (let [model-opt {:adapter (os.getenv :ANVATE_PROVIDER)}
          adapters (require :codecompanion.adapters)]
      (companion.setup
        {:display { :diff {:provider :mini_diff}} 
         :opts {:log_level :DEBUG}
         :strategies {:chat {:adapter model-opt.adapter}
                      :inline {:adapter model-opt.adapter}
                      :agent {:adapter model-opt.adapter}}
         :adapters {:openai (adapters.extend
                              :openai
                              {:env {:api_key (os.getenv :ANVATE_OPENAI_KEY)}
                               :url (.. (os.getenv :ANVATE_OPENAI_HOST) :/chat/completions)
                               :schema {:model {:default (os.getenv :ANVATE_OPENAI_MODEL)}}})}}))))
