(module magic.plugin.fold
  {autoload {nvim aniseed.nvim}})
(let [(ok? fold) (pcall #(require :ufo))]
  (when ok?
    (tset vim.opt :foldcolumn :auto)
    (tset vim.opt :fillchars "eob: ,fold: ,foldopen:,foldclose:")
    (tset vim.opt :foldlevel 99)
    (tset vim.opt :foldlevelstart 99)
    (vim.keymap.set :n
                    :zR
                    fold.openAllFolds)
    (vim.keymap.set :n
                    :zM
                    fold.closeAllFolds)
    (fold.setup {})))
                 ;:close_fold_kinds_for_ft {:default [:imports]}})))
