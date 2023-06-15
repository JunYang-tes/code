(module magic.plugin.leap
  {autoload {nvim aniseed.nvim}})

(let [(ok? leap) (pcall #(require :leap))]
  (when ok?
    (leap.add_default_mappings)))
