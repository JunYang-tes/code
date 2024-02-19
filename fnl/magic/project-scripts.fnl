(module magic.project-scripts)
(fn file-exists [file]
  (let [(stat err) (vim.loop.fs_stat file)]
    (not= nil stat)))

(fn git-root []
  (let [cwd (vim.fn.getcwd)]
    (fn find [path]
      (let [p (.. path "/.git")]
        (if (file-exists p)
          p
          (if (= path "/") nil
              (find (vim.fn.fnamemodify path ":h"))))))
    (find cwd)))

;[<cwd>,.git/.nvim]
(local search-path
  (let [dotnvim (.. (vim.fn.getcwd) "/.nvim")
        git (git-root)]
    (if git
      [dotnvim (.. git "/.nvim")]
      [dotnvim])))



(each [_ v (ipairs search-path)]
  (let [(ok err)
        (pcall #(do)
          (let [path (.. v "/init.lua")]
            (when (file-exists path)
              (dofile path)))
          (let [path (.. v "/init.vim")]
            (when (file-exists path)
              (vim.cmd
                (.. "source " path)))))]
    (if err
      (print :error err))))

