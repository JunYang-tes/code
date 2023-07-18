(module magic.plugin.nvim-cmp)
(set vim.o.completeopt "menu,preview,noinsert")
(set vim.o.pumheight 10)
(local icons
  {
   :Text  ""
   :Method  ""
   :Function  "󰊕"
   :Constructor  ""
   :Field  "󰇽"
   :Variable  ""
   :Class  ""
   :Interface  ""
   :Module  ""
   :Property  "󰜢"
   :Unit  ""
   :Value  "󰎠"
   :Enum  ""
   :Keyword  "󰌋"
   :Snippet  ""
   :Color  "󰏘"
   :File  "󰈙"
   :Reference  ""
   :Folder  "󰉋"
   :EnumMember  ""
   :Constant  "󰏿"
   :Struct  ""
   :Event  ""
   :Operator  "󰆕"
   :TypeParameter  ""})


(fn format [entry vim_item]
  (tset vim_item
        :kind
        (string.format
          "%s %s"
          (. icons vim_item.kind)
          vim_item.kind))
  vim_item)

(let [(ok? cmp) (pcall require :cmp)
      (lsp-expand? lsp_expand) (pcall #(. (require :luasnip) :lsp_expand))]
  (when (not lsp-expand?)
    (print "No lusnip"))
  (when ok?
    ;https://github.com/hrsh7th/nvim-cmp/pull/1611#discussion_r1224151115
    (tset cmp :visible
          (fn []
            (or (cmp.core.view:visible)
                (=
                 1
                 (vim.fn.pumvisible)))))
    (cmp.setup.global
      {
       :snippet {:expand (fn [args]
                           (lsp_expand args.body)
                           nil)}
       :sources (cmp.config.sources
                  [
                   {:name "nvim_lsp"}
                  ; :entry_filter (fn [entry ctx]
                  ;                 (let [types (require :cmp.types)
                  ;                       kind (. types.lsp.CompletionItemKind
                  ;                               (: entry :get_kind))]
                  ;                   (if (= kind :Text)
                  ;                     false
                  ;                     true)))}
                   {:name "buffer"}
                   {:name "path"}])
       :window {:completion {:max_height 300}}
       :formatting {: format}
       :completion {:completeopt "menu,menuone,preview,noinsert"}
       :mapping (cmp.mapping.preset.insert
                  {"<C-b>" (cmp.mapping.scroll_docs -4)
                   "<C-f>" (cmp.mapping.scroll_docs 4)
                   "<C-Space>" (cmp.mapping.complete {:select true})
                   "<C-e>" (cmp.mapping.abort)
                   "<CR>" (cmp.mapping.confirm {:select true})})})
    (cmp.setup.cmdline
      ":"
      {:mapping (cmp.mapping.preset.cmdline)
       :sources (cmp.config.sources
                  [{:name :cmdline}
                   {:name :path}])})
    (cmp.setup.cmdline
      ["/" "?"]
      {:mapping (cmp.mapping.preset.cmdline)
       :sources (cmp.config.sources
                  [{:name :buffer}])})))
