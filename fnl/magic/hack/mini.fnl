(pcall #(do
          (local mini (require :noice.view.backend.mini))
          (var focused-ft "")

          (vim.api.nvim_create_autocmd
            [:BufEnter]
            {:pattern "*"
             :callback (fn []
                         (set focused-ft
                              (vim.api.nvim_buf_get_option
                                0
                                :filetype)))})

          (local can_hide mini.can_hide)
          (tset mini
                :can_hide
                (fn [self message] 
                  (and
                    (can_hide self message)
                    ;没focus 到
                    (not= focused-ft
                       :noice))))))
