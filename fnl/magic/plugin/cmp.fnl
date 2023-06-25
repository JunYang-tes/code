(module magic.plugin.cmp
  {autoload {nvim aniseed.nvim}})

(set nvim.o.completeopt "menu,preview,noinsert")
(set nvim.o.pumheight 10)
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

(let [(ok? cmp) (pcall require :cmp)]
  (when ok?
    (cmp.setup
      {
       :sources [{:name "conjure"}
                 {:name "nvim_lsp"
                  :entry_filter (fn [entry ctx]
                                  (let [types (require :cmp.types)
                                        kind (. types.lsp.CompletionItemKind
                                                (: entry :get_kind))]
                                    (if (= kind :Text)
                                      false
                                      true)))}
                 ;{:name "buffer"}
                 {:name "path"}]
       :window {:completion {:max_height 300}}
       :formatting {: format}
       :completion {:completeopt "menu,menuone,preview,noinsert"}
       :mapping (cmp.mapping.preset.insert
                  {"<C-b>" (cmp.mapping.scroll_docs -4)
                   "<C-f>" (cmp.mapping.scroll_docs 4)
                   "<C-Space>" (cmp.mapping.complete {:select true})
                   "<C-e>" (cmp.mapping.abort)
                   "<CR>" (cmp.mapping.confirm {:select true})})})))
