(module magic.face
  {autoload {
             nvim aniseed.nvim}})

(each [name icon (pairs {:DiagnosticSignError : 
                         :DiagnosticSignWarn : 
                         :DiagnosticSignHint :
                         :DiagnosticSignInfor :})]
    (nvim.fn.sign_define name { :text icon :texthl name  :numhl name}))
(pcall #(nvim.ex.colorscheme :tokyonight))

(defn- get-hlgroup [name fallback]
  (let [
        (ok? hl) (pcall #(if (vim.fn.hlexists name)
                           (let [hl (if vim.api.nvim_get_hl
                                      (vim.api.nvim_get_hl
                                        0 {: name :link false})
                                      (vim.api.nvim_get_hl_by_name
                                        name vim.o.termguicolors))]
                             {:fg (or hl.fg
                                      hl.foreground
                                      :None)
                              :bg (or hl.bg
                                      hl.background)})
                           (or fallback {})))]
    (if ok?
      hl
      (or fallback {}))))

(defn- highlights [tbl]
  (each [group spec (pairs tbl)]
    (vim.api.nvim_set_hl 0 group spec)))

(highlights
  (let [normal (get-hlgroup :Normal)
        main (get-hlgroup :BufferVisible)
        fg normal.fg
        bg normal.bg
        bg-alt (. (get-hlgroup :Visual) :bg)
        str-fg (. (get-hlgroup :String) :fg)
        prompt (get-hlgroup :lualine_a_command)]
    {
     ;:TelescopeBorder  { :fg  bg_alt : bg}
     :TelescopeNormal  { : bg}
     :TelescopePreviewBorder  {  :fg  main.bg :bg  main.bg}
     :TelescopePreviewNormal  { :bg main.bg}
     :TelescopePreviewTitle  { :fg  bg :bg str-fg}
     :TelescopePromptBorder  { :fg  bg_alt :bg  bg_alt}
     :TelescopePromptNormal  { :fg  fg :bg  bg_alt}
     ;:TelescopePromptPrefix  { :fg  prompt-fg :bg  bg_alt}
     :TelescopePromptTitle  { :fg  bg :bg  prompt.bg}
     :TelescopeResultsBorder  { :fg  main.bg :bg  main.bg}
     :TelescopeResultsNormal  { :bg  main.bg}
     :TelescopeResultsTitle  { :fg  main.bg :bg  main.bg}}))
