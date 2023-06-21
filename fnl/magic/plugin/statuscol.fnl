(module magic.plugin.statuscol)
(fn not-a [ft]
  (fn [{: buf}]
    (let [buf (. vim.bo buf)]
      (not= buf.filetype ft))))
(fn not-one-of [fts]
  (fn [{: buf}]
    (let [buf (. vim.bo buf)]
      (accumulate [not-such-ft true
                   _ ft (ipairs fts)]
        (and not-such-ft (= buf.filetype ft))))))
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
       :segments [{:sign {:name [:Diagnostic]
                          :maxwidth 1
                          :auto false}
                   :condition [not-read-only,not-fn-bufs]
                   :click "v:lua.ScSa"}
                  {:text [builtin.foldfunc]
                   :sign {:auto true}
                   :condition [not-fn-bufs]
                   :click "v:lua.ScFa"}
                  {:text [builtin.lnumfunc]
                   :condition [not-fn-bufs]
                   :click "v:lua.ScLa"}
                  {:text ["┃"]
                   :condition [not-fn-bufs]}
                  {:sign {:name [".*"]
                          :maxwidth 1
                          :auto false}
                   :click "v:lua.ScSa"}]})))
