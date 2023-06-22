(module magic.init
  {autoload {plugin magic.plugin
             nvim aniseed.nvim}})

;;; Introduction

;; Aniseed compiles this (and all other Fennel files under fnl) into the lua
;; directory. The init.lua file is configured to load this file when ready.

;; We'll use modules, macros and functions to define our configuration and
;; required plugins. We can use Aniseed to evaluate code as we edit it or just
;; restart Neovim.

;; You can learn all about Conjure and how to evaluate things by executing
;; :ConjureSchool in your Neovim. This will launch an interactive tutorial.


;;; Generic configuration

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

(nvim.ex.set :list)
;(nvim.ex.set :termguicolors)
;; indent with spaces instead of tab
(nvim.ex.set :expandtab)
(nvim.ex.set :nowrap)
(nvim.ex.set :relativenumber)
(vim.diagnostic.config 
  {:virtual_text false
   :signs true})


;;; Mappings

(set nvim.g.mapleader ",")
;;(set nvim.g.maplocalleader " ")
(require :magic.keymap)

;; why macro instead of fn ?
;; Packer will compile config to string which is not support closure.
(macro simple-setup [plugin opts]
  `(fn []
    (let [{:setup setup#} (require ,plugin)]
      (setup# ,opts))))
;;; Plugins

(plugin.use
  :Olical/aniseed {}
  :Olical/nvim-local-fennel {}
  :lewis6991/gitsigns.nvim {:config (simple-setup :gitsigns)}
  :sindrets/diffview.nvim {}
  ;;Diagnostic list
  :folke/trouble.nvim {:mod :trouble}
  ;; Theme
  :folke/tokyonight.nvim {}
  ;; motion
  :ggandor/leap.nvim {}
  :ja-ford/delaytrain.nvim {:config (simple-setup :delaytrain)}
  ;; cmp
  :hrsh7th/cmp-buffer {}
  :hrsh7th/cmp-cmdline {}
  :hrsh7th/cmp-nvim-lsp {}
  :hrsh7th/cmp-path {}
  :hrsh7th/nvim-cmp {:mod :cmp}
  ;;:jiangmiao/auto-pairs {:mod :auto-pairs}
  :windwp/nvim-autopairs {:mod :auto-pairs}
  :lewis6991/impatient.nvim {}
  :mbbill/undotree {:mod :undotree}
  :neovim/nvim-lspconfig {:mod :lspconfig}
  :nvim-lualine/lualine.nvim {:mod :lualine}
  :nvim-lua/plenary.nvim {}
  :nvim-telescope/telescope.nvim {:mod :telescope :requires [[:nvim-lua/popup.nvim] [:nvim-lua/plenary.nvim]]}
  :smartpde/telescope-recent-files {}
  :nvim-treesitter/nvim-treesitter {:mod :tree-sitter
                                    :run #(let [install (require :nvim-treesitter.install)
                                                update (install.update {:with_sync true})]
                                            (update))}
  :nvim-treesitter/nvim-treesitter-textobjects {}
  :RRethy/vim-illuminate {:mod :vim-illuminate}
  :JoosepAlviste/nvim-ts-context-commentstring {}
  :numToStr/Comment.nvim {:config (simple-setup :Comment)}
  :lukas-reineke/indent-blankline.nvim {:config (simple-setup
                                                  :indent_blankline
                                                  {:show_current_context true
                                                   :show_current_context_start true})}
  ;:github/copilot.vim {}
  :tpope/vim-repeat {}
  ; :guns/vim-sexp {}
  ; :tpope/vim-sexp-mappings-for-regular-people { :mod :sexp}
  :tpope/vim-surround {}
  :folke/zen-mode.nvim {}
  :wbthomason/packer.nvim {}
  :nvim-tree/nvim-web-devicons {}
  :NvChad/nvim-colorizer.lua {:config (simple-setup :colorizer)}
  :mrjones2014/nvim-ts-rainbow {}
  :ray-x/lsp_signature.nvim {:mod :lsp_signature}
  :jackMort/ChatGPT.nvim {:mod :gpt
                          :requires [:MunifTanjim/nui.nvim
                                     :nvim-lua/plenary.nvim
                                     :nvim-telescope/telescope.nvim]}
  :j-hui/fidget.nvim {:config (simple-setup :fidget {})
                      :branch :legacy}
  :rlue/vim-barbaric {:mod :barbaric}
  :eraserhd/parinfer-rust {:run "cargo build --release"}
  :mfussenegger/nvim-lint {:mod :nvim-lint}
  ; :anuvyklack/windows.nvim {:requires [:anuvyklack/middleclass]
  ;                           :config (simple-setup :windows)}
  :simrat39/symbols-outline.nvim {:mod :symbols-outline}
  :nvim-telescope/telescope-media-files.nvim {}
  :kevinhwang91/nvim-ufo {:requires :kevinhwang91/promise-async
                          :mod :fold}
  :luukvbaal/statuscol.nvim {:mod :statuscol}
  :williamboman/mason.nvim {:config (simple-setup :mason {})
                            :run :MasonUpdate}
  :nvim-tree/nvim-tree.lua {:mod :nvim-tree})
  
(require :magic.face)
