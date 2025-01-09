(module magic.plugin.lualine
  {autoload {model magic.model}})

(let [(ok? lualine) (pcall require :lualine)]
  (when ok?
    (lualine.setup
      ;{:sections {:lualine_c [#((. (require :lsp-progress) :progress) :filename)]}}
      {:sections {:lualine_c [:filename
                              model.get_model
                              #((. (require :lsp-progress) :progress))]}})))
(model.add_on_change (. (require :lualine) :refresh))
(vim.api.nvim_create_augroup
  :lualine_augroup  {:clear true})
(vim.api.nvim_create_autocmd 
  :User {:group :lualine_augroup
         :pattern :LspProgressStatusUpdated
         :callback (. (require :lualine) :refresh)})
                             
