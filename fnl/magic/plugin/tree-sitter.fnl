(module magic.plugin.tree-sitter
  {autoload {nvim aniseed.nvim
             util magic.util}})
(let [(ok? cfg) (pcall #(require :nvim-treesitter.configs))]
  (when ok?
    (cfg.setup
      {:ensure_installed [:typescript :css :javascript :markdown :markdown_inline :kotlin]
       :highlight {:enable true}
       :indent {:enable true}
       :textobjects {:select {:enable true
                              :keymaps {:af "@function.outer"
                                        :if "@function.inner"}}}})))
