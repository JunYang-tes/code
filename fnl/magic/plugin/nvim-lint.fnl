(module magic.plugin.nvim-lint
  {autoload {util magic.util
             nvim aniseed.nvim}})

(let [(ok? lint) (pcall #(require :lint))]
  (tset lint :linters_by_ft
        {:typescript [:eslint]
         :javascript [:eslint]})
  (vim.api.nvim_create_autocmd
    [:BufWritePost]
    {:callback (fn []
                 (pcall lint.try_lint))}))
