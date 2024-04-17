(module magic.plugin.image
  {autoload {nvim aniseed.nvim
             core aniseed.core}})

(print core.some)
(local image (require :image))
(image.setup)

(vim.api.nvim_create_autocmd
  :BufReadPost
  {:callback (fn [opt]
               (let [name (vim.api.nvim_buf_get_name opt.buf)
                     img-postfix [:%.png :%.ppm :%.tga
                                  :%.gif :%.jpg :%.jpeg]]
                 (when (core.some #(string.match name $1) img-postfix)
                   (let [
                         intance (image.from_file
                                   name
                                   {:buffer opt.buf})]
                     (instance:render)))))})
