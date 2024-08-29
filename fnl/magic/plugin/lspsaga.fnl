(module magic.plugin.lspsaga
  {autoload {util magic.util
             nvim aniseed.nvim}})
(let [lspsaga (require :lspsaga)]
  (lspsaga.setup
    {:lightbulb {:enable false}}))
