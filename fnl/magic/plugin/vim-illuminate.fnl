(module magic.plugin.tree-sitter
  {autoload {nvim aniseed.nvim
             util magic.util}})
(let [(ok? cfg) (pcall #(require :illuminate))]
  (when ok?
    (cfg.configure
      {:providers [:lsp :treesitter]
      :under_cursor true})))
