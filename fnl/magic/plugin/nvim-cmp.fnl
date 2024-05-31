(module magic.plugin.nvim-cmp
  {autoload {util magic.util}})

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
  ;; make it don't too long
  (let [max-length 40
        abbr vim_item.abbr]
    (if (> (string.len abbr) max-length)
      (tset vim_item
            :abbr
            (..
              (string.sub vim_item.abbr 1 20)
              "..."))))
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
                   {:name "buffer"
                    :option {:get_bufnrs (fn []
                                           (let [bufs (vim.api.nvim_list_bufs)
                                                 big-file (fn [buf]
                                                           (let [byte (vim.api.nvim_buf_get_offset 
                                                                       buf
                                                                       (vim.api.nvim_buf_line_count buf))]
                                                            (> byte (* 1024 1024))))
                                                 should-ignore (fn [filename]
                                                                 (util.some [:package-lock.json
                                                                             :pnpm-lock.yaml]
                                                                    #(not= (string.find filename $1 1 true)
                                                                           nil)))]
                                             (icollect [_ bufnum (ipairs bufs)]
                                               (let [filename (vim.api.nvim_buf_get_name bufnum)]
                                                 (if (and (not (should-ignore filename))
                                                          (not (big-file bufnum)))
                                                   bufnum)))))}}
                   {:name "path"}])
       :window {:completion {:max_height 300}}
       :formatting {: format}
       :completion {:completeopt "menu,menuone,preview,noinsert"}
       :mapping (cmp.mapping.preset.insert
                  {"<C-b>" (cmp.mapping.scroll_docs -4)
                   "<C-f>" (cmp.mapping.scroll_docs 4)
                   "<D-space>" (cmp.mapping.complete {:select true})
                   "<C-e>" (cmp.mapping.abort)
                   "<CR>" (cmp.mapping.confirm {:select true})})})))
    ; (cmp.setup.cmdline
    ;   ["/" "?"]
    ;   {:mapping (cmp.mapping.preset.cmdline
    ;               {"<Tab>" {:c (cmp.mapping.confirm)}})
    ;    :sources (cmp.config.sources
    ;               [{:name :buffer}])})))
