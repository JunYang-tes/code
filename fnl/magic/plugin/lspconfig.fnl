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

(let [(ok? lsp) (pcall #(require :lspconfig))
      (cmp? cmp) (pcall #(require :cmp_nvim_lsp))
      capabilities (cmp.default_capabilities)
      (_ util) (pcall #(require :lspconfig/util))]
  (when (and ok? cmp?)
    (lsp.clojure_lsp.setup {: capabilities})
    (lsp.tsserver.setup {: capabilities})
    (lsp.rust_analyzer.setup {: capabilities})
    (setup-fennel lsp capabilities)
;     (lsp.fennel_ls.setup {:settings {:fennel-ls {:macro-path "./src/macros/?.fnl;/home/yj/.config/code/.local/data/nvim/site/pack/packer/start/aniseed/fnl/aniseed/macros.
; fnl"}}})
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
