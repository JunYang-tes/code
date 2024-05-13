(module magic.plugin.markdown-preview)
(tset vim :g :mkdp_auto_close false)

(vim.api.nvim_create_user_command
  :MarkdownPreviewDisableSyncScroll
  (fn []
    (let [opt vim.g.mkdp_preview_options]
      (when opt
        ;not know why (tset vim :g :mkdp_preview_options :disable_sync_scroll 1) not work
        (tset vim :g
              :mkdp_preview_options
              (vim.tbl_extend
                :force
                opt
                {:disable_sync_scroll 1})))))
  {})
(vim.api.nvim_create_user_command
  :MarkdownPreviewEnableSyncScroll
  (fn []
    (let [opt vim.g.mkdp_preview_options]
      (when opt
        (tset vim :g
              :mkdp_preview_options
              (vim.tbl_extend
                :force
                opt
                {:disable_sync_scroll 0})))))
  {})

(vim.api.nvim_create_autocmd
  :BufUnload
  {:callback (fn [opt]
               (vim.cmd
                 "silent call mkdp#rpc#preview_close()"))
   :pattern ["*.md"]})
