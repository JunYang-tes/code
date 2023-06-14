(module magic.plugin.symbols-outline
  {autoload {nvim aniseed.nvim}})

(let [(ok? symbols) (pcall #(require :symbols-outline))]
  (when ok?
    (symbols.setup
      {:width 25})))
