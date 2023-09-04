(module magic.plugin.tree-sitter
  {autoload {nvim aniseed.nvim
             util magic.util}})
(let [(ok? cfg) (pcall #(require :nvim-treesitter.configs))]
  (when ok?
    (cfg.setup
      {:ensure_installed [:typescript :css :javascript]
       :highlight {:enable true}
       :indent {:enable true}
       :context_commentstring {:enable true}
       :textobjects {:enable true
                     :keymaps {:af "@function.outer"
                               :if "@function.inner"}}})))
