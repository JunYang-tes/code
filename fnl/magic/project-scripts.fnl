(module magic.project-scripts)

(fn has-file [name]
  (fn []
    (let [(stat err) (vim.loop.fs_stat
                       (.. (vim.fn.getcwd)
                           "/.nvim/"
                           name))]
      (not= nill stat))))
(local has-lua-init
  (has-file :init.lua))
(local has-vim-init
   (has-file :init.vim))
(let [(ok? err)
      (pcall #(do
                (if (has-lua-init)
                  (do
                    (tset package
                          :path
                          (.. package.path ";"
                              (.. (vim.fn.getcwd)
                                  "/.nvim/?.lua")))
                    (require :init)))
                (if (has-vim-init)
                  (vim.cmd
                    (.. "source " (vim.fn.getcwd)
                        "/.nvim/init.vim")))))]
  (if (not ok?)
    (print err)))
