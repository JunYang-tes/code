(module magic.keymap
  {autoload {
             nvim aniseed.nvim
             util magic.util}})

(defn- map [from to]
  (util.noremap from to))
(defn- nmap [from to]
  (util.nnoremap from to))
(defn- lnnmap [from to]
  (util.lnnoremap from to))
(defn- tnomap [from to]
  (nvim.set_keymap :t from to {}))
(defn- map-cmd [mode key cmd]
  (vim.keymap.set mode
                  key
                  (.. :<cmd> cmd :<cr>)))
(defn- map-plug [mode key cmd]
  (vim.keymap.set mode
                  key
                  (.. :<Plug> "(" cmd ")")))

(map :q ":bd!<cr>")
(map "<leader>wc" "<C-w>c")
(map "<leader>wh" "<C-w>h")
(map "<leader>wl" "<C-w>l")
(map "<leader>wk" "<C-w>k")
(map "<leader>wj" "<C-w>j")
(map "<space><tab>" ":b#<CR>")
;anuvyklack/windows.nvim
(map-cmd :n :<leader>wz :WindowsMaximize)
(map-cmd :n :<leader>w= :WindowsEqualize)
(map :ge ":NvimTreeToggle<CR>")
(map "[b" ":bpre<CR>")
(map "]b" ":bnext<CR>")
(map-cmd :n "[d" "Lspsaga diagnostic_jump_prev")
(map-cmd :n "]d" "Lspsaga diagnostic_jump_next")
(map "[e" ":lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>")
(map "]e" ":lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>")
(nmap "[t" "tabpre")
(nmap "]t" "tabnext")
(nmap "[h" "Gitsign prev_hunk")
(nmap "]h" "Gitsign next_hunk")
;lsp
(map-cmd :n :gd "Lspsaga goto_definition")
(nmap :gD "lua vim.lsp.buf.declaration()")
(map-cmd :n :gr "Lspsaga finder ref ")
(nmap :gi "lua vim.lsp.buf.implementation()")
(map-cmd :n :K "Lspsaga hover_doc")
(map-cmd :n :go "Lspsaga outline")
(nmap :<c-k> "lua vim.lsp.buf.signature_help()")

(map-cmd :n :<leader>lr "Lspsaga rename")
(map-cmd :n :<leader>la "Lspsaga code_action")
(lnnmap :lf "lua vim.lsp.buf.format()")

(lnnmap :z :ZenMode)
(lnnmap :sr ":Telescope resume")
(lnnmap :sf ":Telescope find_files")
(lnnmap :sg "Telescope live_grep ")
(lnnmap :sb "Telescope buffers")
(lnnmap :sc "Telescope commands")
(lnnmap :sq "Telescope quickfix")
(lnnmap :ss "Telescope git_status")
(lnnmap :sh "lua require('telescope').extensions.recent_files.pick()")
(lnnmap :sla "Telescope lsp_code_actions")
(lnnmap :slr "Telescope lsp_references")
(lnnmap :sls "Telescope lsp_document_symbols")

(map-plug :n :s :leap-forward-to)
(map-plug :n :S :leap-backward-to)
(map-plug :n :gs :leap-from-window)


(tnomap "<esc>" "<C-\\><C-n>")
