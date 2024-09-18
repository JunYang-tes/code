(module magic.plugin.lualine)

(let [(ok? lualine) (pcall require :lualine)]
  (when ok?
    (lualine.setup
      {:sections {:lualine_c [#((. (require :lsp-progress) :progress))]}})))

(vim.api.nvim_create_augroup
  :lualine_augroup  {:clear true})
(vim.api.nvim_create_autocmd 
  :User {:group :lualine_augroup
         :pattern :LspProgressStatusUpdated
         :callback (. (require :lualine) :refresh)})
                             
