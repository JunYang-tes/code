(module magic.plugin.lspconfig
  {autoload {util magic.util
             nvim aniseed.nvim}})

(defn- map [from to]
  (util.nnoremap from to))

(defn- setup-fennel [lsp]
  (let [pwd (vim.loop.cwd)]
    (pcall
      #(with-open [cfg (io.open (.. pwd "/" ".fennel-ls.json"))]
        (let [fennel-ls
              (-> (cfg:read "*a")
                  vim.json.decode)]
          (lsp.fennel_ls.setup {:settings {: fennel-ls}}))))))

(let [(ok? lsp) (pcall #(require :lspconfig))
      (_ util) (pcall #(require :lspconfig/util))]
  (when ok?
    (lsp.clojure_lsp.setup {})
    (lsp.tsserver.setup {})
    (lsp.rust_analyzer.setup {})
    (setup-fennel lsp)
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
    (lsp.jsonls.setup {})))

    ;; https://www.chrisatmachine.com/Neovim/27-native-lsp/
