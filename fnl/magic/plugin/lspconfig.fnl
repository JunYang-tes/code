(module magic.plugin.lspconfig
  {autoload {util magic.util
             nvim aniseed.nvim}})

(defn- map [from to]
  (util.nnoremap from to))

(let [(ok? lsp) (pcall #(require :lspconfig))]
  (when ok?
    (lsp.clojure_lsp.setup {})
    (lsp.tsserver.setup {})

    ;; https://www.chrisatmachine.com/Neovim/27-native-lsp/
    ))
