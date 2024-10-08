(module vscode.init
  {autoload {plugin magic.plugin
             nvim aniseed.nvim}})
(vim.loader.enable)

(nvim.ex.set :number)
(set nvim.o.termguicolors true)
(set nvim.o.mouse "a")
(set nvim.o.updatetime 500)
(set nvim.o.timeoutlen 500)
(set nvim.o.sessionoptions "blank,curdir,folds,help,tabpages,winsize")
(set nvim.o.inccommand :split)
(set nvim.o.signcolumn :yes)
;;tab
(set nvim.o.tabstop 2)
(set nvim.o.shiftwidth 2)
(set nvim.o.termguicolors true)
(vim.cmd "set formatoptions-=o")
;(nvim.ex.set :termguicolors)
;; indent with spaces instead of tab
(nvim.ex.set :expandtab)
(nvim.ex.set :relativenumber)
(vim.diagnostic.config 
  {:virtual_text false
   :signs true})
(fn hyhird [tbl ...]
  (each [i v (ipairs [...])]
    (tset tbl i v))
  tbl)

(macro simple-setup [plugin opts]
  `(fn []
    (let [{:setup setup#} (require ,plugin)]
      (setup# ,opts))))

;;; Mappings
(set nvim.g.mapleader ",")
(require :vsc.keymap)

(plugin.use
  :tpope/vim-surround {}
  :stevearc/oil.nvim {:config (fn []
                                ((. (require :oil) :setup) {})
                                (vim.keymap.set :n "-"
                                                :<cmd>Oil<cr>))}
  :lewis6991/gitsigns.nvim {:config (simple-setup :gitsigns)}
  :folke/flash.nvim {:keys [
                            ; (hyhird {:mode [:n :o :x]} :jj #((-> :flash
                            ;                                     require
                            ;                                     (. :jump))
                            ;                                  {:search {:mode :search}
                            ;                                   :label {:after [0 0]}
                            ;                                   :pattern "^"}))
                            (hyhird {:mode [:n :o :x]} :s #((-> :flash
                                                               require
                                                               (. :jump))))
                            (hyhird {:mode [:n :o :x]} :S #((-> :flash
                                                               require
                                                               (. :treesitter))))]})
  
