(print :load-keymap)
(module magic.keymap
  {autoload {
             nvim aniseed.nvim
             util magic.util}})
(local vscode (require :vscode-neovim))

(defn- map [from to]
  (util.noremap from to))
(defn- nmap [from to]
  (util.nnoremap from to))

(defn- map-cmd [mode key cmd]
  (vim.keymap.set mode
                  key
                  (.. :<cmd> cmd :<cr>)))

(defn- map-action [mode key action opts]
  (vim.keymap.set mode key
                  (fn []
                    (vscode.action
                      action opts))))

(map "<space><tab>" "<cmd>b#<CR>")
(map :j :gj)
(map :k :gk)
(nmap "[t" "tabpre")
(nmap "]t" "tabnext")
(nmap "[h" "Gitsign prev_hunk")
(nmap "]h" "Gitsign next_hunk")
(map-action
  :n
  :ge
  :workbench.view.explorer)

(map-action
  :n
  "[d"
    :editor.action.marker.next)
(map-action
  :n
  "]d"
    :editor.action.marker.prev)

(map-action
  :n :<leader>lr
  :editor.action.rename)

(map-action
  :n :<leader>sr
  :find-it-faster.resume_search)

(map-action
  :n
  :<leader>sf
  :find-it-faster.findFiles)

(map-action
  :n :<leader>sg
  :find-it-faster.findWithinFiles)

(map-action
  :n :<leader>ss
  :find-it-faster.pickFileFromGitStatus)

(map-action
  :n :<leader>so
  :editor.action.accessibleViewGoToSymbol)

(map-action
  :n
  :<leader>sb
  :workbench.action.quickOpenNavigateNextInFilePicker)

(map-action
  :n
  :<leader>lf
  :editor.action.formatDocument)

(vim.keymap.set
  :v :p "\"_dP" {:noremap true})
