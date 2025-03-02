(module magic.plugin.avante {autoload {nvim aniseed.nvim
                                       util magic.util
                                       model_fn magic.model
                                       telescope telescope.pickers}})
(fn is_supported [kind]
  (let [(ok) (pcall require (.. :avante "."
                                :providers "." 
                                kind))]
    return ok))

(fn get-setup-param [model]
  (local vendors {})
  (each [proxy-name proxy (pairs (model_fn.get-proxies))]
    (let [kind (. proxy :kind)
          options (or (. proxy :options)
                      {})
          compatible (. proxy :compatible)]
      (each [_ model (ipairs proxy.models)]
        (let [[model price] (if (= (type model) :string)
                                [model ""]
                                model)
              name (.. proxy-name "/" model price)]
          (tset vendors name
                {:__inherited_from (if (is_supported kind)
                                       kind compatible)
                 :endpoint proxy.baseUrl
                 :disable_tools (not (?. options model :tools))
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
    (let [gemini (require :avante.providers.gemini)]
      (tset gemini :parse_response_without_stream
            (fn [data _ opts])))
      
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
      (avante.setup (get-setup-param model)))
    (fn model-picker []
      (model_fn.model-picker switch-model))
    (vim.api.nvim_create_user_command
      :PreferAvante
      #(model_fn.save-prefered-ai-plugin :avante)
      {:desc "Prefer Avante"})
    (model_fn.add_on_change
      #(let [m (model_fn.get_model)]
         (vim.cmd (.. "AvanteSwitchProvider " m))))))

