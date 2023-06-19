(module magic.plugin.lspconfig
  {autoload {util magic.util
             nvim aniseed.nvim}})

(defn- map [from to]
  (util.nnoremap from to))

(let [(ok? lsp) (pcall #(require :lspconfig))
      (_ util) (pcall #(require :lspconfig/util))]
  (when ok?
    (lsp.clojure_lsp.setup {})
    (lsp.tsserver.setup {})
    (lsp.rust_analyzer.setup {})
    (lsp.fennel_ls.setup {:macro-path "./src/macros/?.fnl"})
    (lsp.pyright.setup 
      {
       :before_init (fn [_ config]
                      (tset config.settings
                            :pythonPath
                            (if vim.env.VIRTUAL_ENV
                              vim.env.VIRTUAL_ENV
                              (or
                                (exepath :python3)
                                (exepath :python)))))})
                        
    (lsp.jsonls.setup {})))

    ;; https://www.chrisatmachine.com/Neovim/27-native-lsp/
    
