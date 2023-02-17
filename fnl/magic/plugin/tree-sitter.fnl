(module magic.plugin.tree-sitter
  {autoload {nvim aniseed.nvim
             util magic.util}})
(let [(ok? cfg) (pcall #(require :nvim-treesitter.configs))]
  (when ok?
    (cfg.setup
      {:ensure_installed [:typescript :css]
       :highlight {:enable true}
       :context_commentstring {:enable true}
       :rainbow {:enable true}})))
