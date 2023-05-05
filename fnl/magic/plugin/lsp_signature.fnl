(module magic.plugin.cmp
  {autoload {nvim aniseed.nvim}})


(let [(ok? s) (pcall require :lsp_signature)]
  (when ok?
    (s.setup { :floating_window false})))
