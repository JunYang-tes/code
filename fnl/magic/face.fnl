(module magic.face
  {autoload {
             nvim aniseed.nvim}})

(each [name icon (pairs {:DiagnosticSignError : 
                         :DiagnosticSignWarn : 
                         :DiagnosticSignHint :
                         :DiagnosticSignInfor :})]
    (nvim.fn.sign_define name { :text icon :texthl name  :numhl name}))
(pcall #(nvim.ex.colorscheme :tokyonight))
