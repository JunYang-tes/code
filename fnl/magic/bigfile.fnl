(module magic.bigfile
  {autoload {util magic.util
             lazy lazy}})

(vim.api.nvim_create_autocmd
  :LspAttach
  {:callback (fn [opt]
               (when (util.is-a-big-file
                       opt.buf)
                 (vim.schedule
                   #(vim.lsp.buf_detach_client
                      opt.buf
                      opt.data.client_id))))})

(vim.api.nvim_create_autocmd
  :BufReadPost
  {:callback (fn [opt]
               (when (and (util.is-a-big-file opt.buf)
                          (util.has-long-line opt.buf))
                 (vim.api.nvim_buf_set_option
                   opt.buf
                   "filetype"
                   "txt")
                 (vim.cmd "set wrap")))})
