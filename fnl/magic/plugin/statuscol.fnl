(module magic.plugin.statuscol)
(pcall 
  #(let [statuscol (require :statuscol)
         builtin (require :statuscol.builtin)]
    (statuscol.setup
      {:relculright true
       :setopt true
       :segments [{:sign {:name [:Diagnostic]
                          :auto true}
                   :click "v:lua.ScSa"}
                  {:text [builtin.foldfunc]
                   :click "v:lua.ScLa"}
                  {:text [builtin.lnumfunc]
                   :click "v:lua.ScLa"}
                  {:text ["┃"]}
                  {:sign {:name [".*"]
                          :auto false}
                   :click "v:lua.ScSa"}]})))
