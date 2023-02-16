(module magic.keymap
  {autoload {util magic.util}})

(defn- map [from to]
  (util.noremap from to))
(defn- lnnmap [from to]
  (util.lnnoremap from to))

(map :q ":bd!<cr>")
(map "<space>wc" "<C-w>c")
(map "<space>wh" "<C-w>h")
(map "<space>wl" "<C-w>l")
(map "<space>wk" "<C-w>k")
(map "<space>wj" "<C-w>j")
(map "<space><tab>" ":b#<CR>")
(map :ge ":NvimTreeToggle<CR>")
(map "[b" ":bpre<CR>")
(map "]b" ":bnext<CR>")
(map "[d" ":lua vim.diagnostic.goto_prev()<CR>")
(map "]d" ":lua vim.diagnostic.goto_next()<CR>")
(map "[e" ":lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>")
(map "]e" ":lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>")

(lnnmap :z :ZenMode)
(lnnmap :sf ":Telescope find_files")
(lnnmap :sg "Telescope live_grep")
(lnnmap :sb "Telescope buffers")
(lnnmap :sc "Telescope commands")
(lnnmap :sq "Telescope quickfix")
(lnnmap :ss "Telescope git_status")
(lnnmap :sh "lua require('telescope').extensions.recent_files.pick()")
(lnnmap :sla "Telescope lsp_code_actions")
(lnnmap :slr "Telescope lsp_references")
(lnnmap :sls "Telescope lsp_document_symbols")
