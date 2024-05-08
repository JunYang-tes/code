(vim.api.nvim_create_user_command
  :PasteImg
  (fn [{: name : args
        : fargs}]
    (if (= (length fargs) 0)
      (print "Usage: PasteImg [filename] [path]")
      (let [[filename path] fargs
            {: paste_img } (require :clipboard-image.paste)
            path (or path
                     ;; default to buffer's path
                     (vim.fn.expand :%:p:h))]
        (paste_img
          {:img_name filename
           :img_dir path}))))
  {:desc "Paste Image"
   :nargs "*"})
