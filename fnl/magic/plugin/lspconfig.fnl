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

(defn- setup-vtsls [lsp capabilities]
  (let [(ok? lsp-cfg) (pcall #(require :lspconfig.configs))
        (vtsls? vtsls) (pcall #(require :vtsls))]
    (when (and ok? vtsls?)
      (tset lsp-cfg :vtsls vtsls.lspconfig)
      (lsp.vtsls.setup {: capabilities}))))

(fn get-capabilities []
  (let [(ok? cmp) (pcall #(require :cmp_nvim_lsp))]
    (if ok
      (cmp.default_capabilities)
      (vim.lsp.protocol.make_client_capabilities))))

(fn is-deno []
  (let [(stat err) (vim.loop.fs_stat
                     (.. (vim.fn.getcwd)
                         "/"
                         :deno.jsonc))]
    (not= nil stat)))

(let [(ok? lsp) (pcall #(require :lspconfig))
      capabilities (get-capabilities)
      (_ util) (pcall #(require :lspconfig/util))]
  ;; nvim-ufo
  (tset capabilities.textDocument :foldingRange
        {:dynamicRegistration false
         :lineFoldingOnly true})
  (when ok?
    (lsp.clojure_lsp.setup {: capabilities})
    (if (is-deno)
      (lsp.denols.setup {: capabilities})
      (setup-vtsls lsp capabilities))
    (lsp.rust_analyzer.setup {: capabilities})
    (lsp.clangd.setup {: capabilities})
    (lsp.tailwindcss.setup {: capabilities})
    (setup-fennel lsp)
    (lsp.pyright.setup
      {
       : capabilities
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
