(module magic.plugin.avante
  {autoload {nvim aniseed.nvim
             model_fn magic.model
             telescope telescope.pickers}})

(fn get-provider [model]
  (let [[proxy-name model-name] (model_fn.parse-model model)
        proxy (. (model_fn.get-proxies) proxy-name)]
    (if (not= proxy nil)
      (let [
            setup-param {:provider proxy.kind
                         :behaviour {:support_paste_from_clipboard true}
                         :debug true}]
         (tset setup-param
               proxy.kind
               {:endpoint proxy.endpoint
                :model model-name
                :api_key_name (if proxy.local 
                                ""
                                (.. :avante_key_ proxy-name))})
         setup-param)
      (do 
        (print "Not Found" model)
        {}))))

(let [(ok? avante) (pcall require :avante)]
  (when ok?
    (local config (require :avante.config))
    (local providers (require :avante.providers))
    (avante.setup (get-provider (model_fn.get_model)))
    (fn switch-model [model]
      (model_fn.save_model model)
      (let [params (get-provider model)
            providers (require :avante.providers)] 
        (tset providers 
              params.provider
              (vim.tbl_extend :force
                              (. providers params.provider)
                              (. params params.provider)))
        (avante.setup (get-provider model))))
    (fn model-picker []
      (model_fn.model-picker switch-model))
    (vim.api.nvim_create_user_command
      :SwitchModel
      (fn []
        (model-picker))
      {:desc "Switch Model"})))

