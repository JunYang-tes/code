(module magic.cmds
  {autoload {nvim aniseed.nvim
             util magic.util}})

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

(vim.api.nvim_create_user_command
  :Search
  #((. (require :spectre) :toggle))
  {:desc "Search & Replace"
   :nargs 0})

(vim.api.nvim_create_user_command
  :OpenLog
  #(let [path (vim.fn.stdpath :log)
         iter (vim.iter (vim.fn.readdir path))
         files (-> iter
                   (: :map #(.. path "/" $1))
                   (: :filter #(string.match $1 "%.log$")))]
     (util.pick 
       (files:totable)
       "Select log"
       (fn [file]
         (vim.cmd (.. "e " file)))))

  {:desc "Open log"
   :nargs 0})
