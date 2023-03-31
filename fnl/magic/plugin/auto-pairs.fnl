(module magic.plugin.auto-pairs
  {autoload {nvim aniseed.nvim}
   require-macros [magic.macros]})

;(defn setup []
;  (let [auto-pairs nvim.g.AutoPairs]
;    (when auto-pairs
;      (tset auto-pairs "'" nil)
;      (tset auto-pairs "`" nil)
;      (set nvim.b.AutoPairs auto-pairs))))

;(augroup auto-pairs-config
;  (nvim.ex.autocmd
;    :FileType "clojure,fennel,scheme"
;    (.. "call v:lua.require('" *module-name* "').setup()")))
(let [(ok? auto-pairs) (pcall require :nvim-autopairs)
      (_ rule) (pcall require :nvim-autopairs.rule)
      (_ conds) (pcall require :nvim-autopairs.conds)]
  (when ok?
    (auto-pairs.setup {})
    (auto-pairs.add_rules
      [(-> (rule "{" "}")
           (: :with_move (conds.none)))])))
