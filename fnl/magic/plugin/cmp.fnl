(module magic.plugin.cmp
  {autoload {nvim aniseed.nvim}})

(set nvim.o.completeopt "menuone")

(let [(ok? cmp) (pcall require :cmp)]
  (when ok?
    (cmp.setup
      {:sources [{:name "conjure"}
                 {:name "nvim_lsp"
                  :entry_filter (fn [entry ctx]
                                  (let [types (require :cmp.types)
                                        kind (. types.lsp.CompletionItemKind
                                                (: entry :get_kind))]
                                    (if (= kind :Text)
                                      false
                                      true)))}
                 {:name "buffer"}
                 {:name "path"}]
       :mapping (cmp.mapping.preset.insert
                  {"<C-b>" (cmp.mapping.scroll_docs -4)
                   "<C-f>" (cmp.mapping.scroll_docs 4)
                   "<C-Space>" (cmp.mapping.complete)
                   "<C-e>" (cmp.mapping.abort)
                   "<CR>" (cmp.mapping.confirm {:select true})})})))
