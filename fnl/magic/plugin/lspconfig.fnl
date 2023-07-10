(module magic.plugin.lspconfig
  {autoload {util magic.util
             nvim aniseed.nvim}})

(defn- map [from to]
  (util.nnoremap from to))

(defn- setup-fennel [lsp capabilities]
  (let [pwd (vim.loop.cwd)]
    (pcall
      #(with-open [cfg (io.open (.. pwd "/" ".fennel-ls.json"))]
        (let [fennel-ls
              (-> (cfg:read "*a")
                  vim.json.decode)]
          (lsp.fennel_ls.setup {:settings {: fennel-ls}
                                : capabilities}))))))
(fn get-tsserver-path []
  (let [(ok? ret)
        (pcall #(with-open [f (io.popen
                                "which node")]
                  (f:read "*a")))]
    (if ok?
      (let [(r _)
            (string.gsub ret "bin/node%s$" "lib/node_modules/typescript/lib/tsserver.js")]
        r)
      nil)))
(let [(ok? lsp) (pcall #(require :lspconfig))
      (cmp? cmp) (pcall #(require :cmp_nvim_lsp))
      capabilities (if cmp?
                     (cmp.default_capabilities)
                     nil)
      (_ util) (pcall #(require :lspconfig/util))]
  (when (and ok?)
    (lsp.clojure_lsp.setup {: capabilities})
    (lsp.tsserver.setup {: capabilities
                         :cmd (let [path (get-tsserver-path)]
                                (if path
                                  [:typescript-language-server
                                   :--stdio
                                   :--tsserver-path
                                   path]
                                  nil))})
    (lsp.rust_analyzer.setup {: capabilities})
    (lsp.clangd.setup {: capabilities})
    (setup-fennel lsp capabilities)
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
    (lsp.jsonls.setup {: capabilities})))

    ;; https://www.chrisatmachine.com/Neovim/27-native-lsp/
