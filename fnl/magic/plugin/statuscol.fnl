(module magic.plugin.statuscol)
(fn not-a [ft]
  (fn [{: buf}]
    (let [buf (. vim.bo buf)]
      (not= buf.filetype ft))))
(fn not-one-of [fts]
  (fn [{: buf}]
    (let [buf (. vim.bo buf)
          f   (length (icollect [_ ft (ipairs fts)]
                        (if (= ft buf.filetype)
                          ft)))]
      (= f 0))))
(fn not-read-only [{: buf}]
  (let [buf (. vim.bo buf)]
    (. buf :modifiable)))
(pcall
  #(let [statuscol (require :statuscol)
         builtin (require :statuscol.builtin)
         not-fn-bufs (not-one-of [:Outline
                                  :NvimTree
                                  :Trouble])]
    (statuscol.setup
     {:relculright true
      :setopt true
      :segments [{:sign {:name [:Diagnostic]}
                  :condition [not-fn-bufs]
                  :click "v:lua.ScSa"}
                 {:text [builtin.foldfunc]
                  :click "v:lua.ScFa"
                  :condition [not-fn-bufs]}
                 {:text [builtin.lnumfunc]
                  :condition [not-fn-bufs]
                  :click "v:lua.ScLa"}
                 {:text ["┃"]
                  :condition [not-fn-bufs]}
                 {:sign {:name [".*"]
                         :auto false}
                  :click "v:lua.ScSa"}]})))
