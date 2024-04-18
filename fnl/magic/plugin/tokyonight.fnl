(module magic.plugin.tokyonight
  {autoload {nvim aniseed.nvim}})
(let [setup (. (require :tokyonight) :setup)]
  (setup
    {:on_highlights (fn [hl c]
                      (tset hl :DiagnosticUnnecessary
                            {:fg c.fg}))}))
