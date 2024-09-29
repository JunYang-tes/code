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

(vim.api.nvim_create_user_command 
  :LspDeno
  (fn []
    (let [lsp (require :lspconfig)]
      (vim.api.nvim_command "LspStop 0 (vtsls)")
      (vim.api.nvim_command "LspStart denols")))
  {})

(let [(ok? lsp) (pcall #(require :lspconfig))
      capabilities (get-capabilities)
      (_ util) (pcall #(require :lspconfig/util))]
  ;; nvim-ufo
  (tset capabilities.textDocument :foldingRange
        {:dynamicRegistration false
         :lineFoldingOnly true})
  (tset capabilities :textDocument :completion :completionItem :snippetSupport
        true)
  (when ok?
    (lsp.clojure_lsp.setup {: capabilities})
    (lsp.denols.setup {: capabilities
                       :autostart (is-deno)
                       :single_file_support true})
    (lsp.vtsls.setup {: capabilities
                      :settings {:typescript {:inlayHints {:parameterNames {:enable :all}
                                                           :parameterTypes {:enable true}
                                                           :variableTypes {:enable true}
                                                           :propertyDeclarationTypes {:enable true}
                                                           :functionLikeReturnTypes {:enable true}
                                                           :enumMemberValues {:enable true}}}}
                      :autostart (not (is-deno))})
    (lsp.rust_analyzer.setup {: capabilities})
    (lsp.clangd.setup {: capabilities})
    (lsp.cmake.setup {: capabilities})
    (lsp.svelte.setup {: capabilities})
    (lsp.gopls.setup {: capabilities})
    ;(lsp.dartls.setup {: capabilities})
    ;(lsp.tailwindcss.setup {: capabilities})
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
