(module magic.plugin.avante
  {autoload {nvim aniseed.nvim
             util magic.util
             model_fn magic.model
             telescope telescope.pickers}})

(fn get-setup-param [model]
  (local vendors {})
  (each [proxy-name proxy (pairs (model_fn.get-proxies))]
    (let [kind (. proxy :kind)
          compatible (. proxy :compatible)
          endpoint (. proxy :endpoint)]
      (each [_ model (ipairs proxy.models)]
        (let [[model price] (if (= (type model) :string)
                                [model ""]
                                model)
              name (.. proxy-name "/" model price)]
          (tset vendors name
                {:__inherited_from kind
                 :endpoint endpoint
                 :api_key_name (.. :avante_key_ proxy-name)
                 :model model})))))
  (let [provider (if (not= nil (. vendors model))
                   model
                   (util.first-key vendors))]
    {:provider provider
     :behaviour {:support_paste_from_clipboard true}
     :debug true
     : vendors}))

(let [(ok? avante) (pcall require :avante)]
  (when ok?
    (let [model-name (model_fn.get_model)
          param (get-setup-param (model_fn.get_model))]
      (avante.setup param)
      (if (not= param.provider
                model-name)
        (do
          (print (.. :No " " model-name))
          (model.save_model param.provider))))
    
    (fn switch-model [model]
      (model_fn.save_model model)
      (avante.setup (get-provider model)))
    (fn model-picker []
      (model_fn.model-picker switch-model))
    (vim.api.nvim_create_user_command
      :PreferAvante
      #(model_fn.save-prefered-ai-plugin :avante)
      {:desc "Prefer Avante"})
    (vim.api.nvim_create_user_command
      :SwitchModel
      (fn []
        (model-picker))
      {:desc "Switch Model"})))

