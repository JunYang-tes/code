(vim.loader.enable)
(module magic.init
  {autoload {plugin magic.plugin
             nvim aniseed.nvim}})

(require :magic.diagnostics)
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
(set nvim.o.laststatus 3)
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

(local use-coq (not= (os.getenv :COQ)
                     nil))
(local use-cmp (not use-coq))

(local use-companion (not= (os.getenv :COMPANION)
                        nil))
(local use-avante (not use-companion))


(plugin.use
  :Olical/aniseed {}
  :Olical/nvim-local-fennel {}
  :lewis6991/gitsigns.nvim {:config (simple-setup :gitsigns)}
  :sindrets/diffview.nvim {}
  ;;Diagnostic list
  :folke/trouble.nvim {:mod :trouble}
  ;; Theme
  :folke/tokyonight.nvim {:mod :tokyonight}
  ;; motion
  ;:ggandor/leap.nvim {}
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
                                                               (. :treesitter))))]}
  ; "https://git.sr.ht/~marcc/BufferBrowser" {:config (simple-setup
  ;                                                     :buffer_browser
  ;                                                     {:filetype_filters [:TelescopePrompt :NvimTree]})
  ;                                           :lazy false}
  ;; cmp
  :hrsh7th/cmp-buffer {:cond use-cmp}
  :hrsh7th/cmp-cmdline {:cond use-cmp}
  :hrsh7th/cmp-nvim-lsp {:cond use-cmp}
  :hrsh7th/cmp-path {:cond use-cmp}
  :hrsh7th/nvim-cmp {:cond use-cmp :mod :nvim-cmp
                     :commit :b356f2c}
  :L3MON4D3/LuaSnip {:cond use-cmp}
  :Exafunction/codeium.vim {:event :BufEnter}
  ;; another cmp
  :ms-jpq/coq_nvim {:cond use-coq
                    :branch :coq
                    :init (fn [] (tset vim :g :coq_settings {:auto_start true
                                                             :display {:pum {:fast_close false}}
                                                             :keymap {:pre_select true}}))
                    :lazy false}

  :nvimdev/lspsaga.nvim {:lazy false
                         :mod :lspsaga
                         :requires [:nvim-tree/nvim-web-devicons]}
                         
  ;; ts lsp
  :yioneko/nvim-vtsls {:config (fn [] 
                                 ((. (require :vtsls) :config) {}))}
  ;:jiangmiao/auto-pairs {:mod :auto-pairs}
  :windwp/nvim-autopairs {:mod :auto-pairs}
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
  :numToStr/Comment.nvim {:config (fn []
                                    (let [setup (. (require :Comment) :setup)
                                          create_hook (. (require :ts_context_commentstring.integrations.comment_nvim)
                                                         :create_pre_hook)]
                                       (setup {:pre_hook (create_hook)})))}
  :lukas-reineke/indent-blankline.nvim {:config (simple-setup
                                                  :ibl
                                                  {})}
  ;:github/copilot.vim {}
  :tpope/vim-repeat {}
  :guns/vim-sexp {:lazy false}
  :tpope/vim-sexp-mappings-for-regular-people {:mod :sexp
                                               :lazy false}
  :tpope/vim-surround {}
  :folke/zen-mode.nvim {}
  :nvim-tree/nvim-web-devicons {}
  :norcalli/nvim-colorizer.lua {:config (simple-setup :colorizer)}
  :ray-x/lsp_signature.nvim {:mod :lsp_signature}
  ;progress
  ; :j-hui/fidget.nvim {:config (simple-setup :fidget 
  :linrongbin16/lsp-progress.nvim {:config (simple-setup :lsp-progress)}                                          
  ;                                           {:notification { :window {:max_height 5}}})}
  ;im switcher
  :rlue/vim-barbaric {:mod :barbaric}
  :eraserhd/parinfer-rust {:run "cargo build --release"}
  :mfussenegger/nvim-lint {:mod :nvim-lint}
  :anuvyklack/windows.nvim {:requires [:anuvyklack/middleclass]
                            :config {:autowidth {:enable false}}}
  ;:simrat39/symbols-outline.nvim {:mod :symbols-outline}
  :nvim-telescope/telescope-media-files.nvim {}
  ;fold
  :kevinhwang91/nvim-ufo {:requires :kevinhwang91/promise-async
                          :mod :fold}
  :luukvbaal/statuscol.nvim {:mod :statuscol}
  :williamboman/mason.nvim {:config (simple-setup :mason {})
                            :run :MasonUpdate}
  ;:Exafunction/codeium.vim {}
  :s1n7ax/nvim-window-picker {:version "2.*"
                              :event :VeryLazy
                              :window :window-picker
                              :config {:hint :floating-big-letter
                                       :filter_func (fn [ids]
                                                      ids)}}
  :bfredl/nvim-luadev {}
  ;structure search
  :cshuaimin/ssr.nvim {}
  :yj/ai-assistant.nvim {:dev true
                         :lazy false}
  :numtostr/FTerm.nvim {}
  ;sudo 
  :lambdalisue/suda.vim {}
  :NMAC427/guess-indent.nvim {:config (simple-setup :guess-indent {})}
  :nvim-tree/nvim-tree.lua {:mod :nvim-tree}
  :JunYang-tes/markdown-preview.nvim   {:cmd [:MarkdownPreview]
                                        :build "cd app && yarn install"
                                        :mod :markdown-preview
                                        :ft [:markdown]}
  :vhyrro/luarocks.nvim
   {:priority 1001
    :opts {:rocks [:magick]}}
  :3rd/image.nvim {:dependencies [:luarocks.nvim]
                   :mod :image}
  :MunifTanjim/nui.nvim {}
  ;; outline
  :stevearc/aerial.nvim {:config (fn []
                                   (vim.keymap.set :n
                                                   :go
                                                  :<cmd>AerialToggle!<cr>)
                                   ((. (require :aerial) :setup)))}
  :windwp/nvim-ts-autotag {:config (simple-setup
                                     :nvim-ts-autotag
                                     {:opts {:enable_close true
                                             :enable_rename true
                                             :enable_close_on_slash false}})}
  :MysticalDevil/inlay-hints.nvim {:config (simple-setup :inlay-hints {})}
  :akinsho/flutter-tools.nvim {:config (simple-setup :flutter-tools {})}
  :yetone/avante.nvim {:dependencies [:stevearc/dressing.nvim
                                      :nvim-lua/plenary.nvim
                                      :MunifTanjim/nui.nvim
                                      (hyhird
                                        {:event :VeryLazy
                                         :opts {:default {:embed_image_as_base64 false
                                                          :prompt_for_file_name false
                                                          :drag_and_drop {:insert_mode true}}}}
                                        :HakonHarnes/img-clip.nvim)
                                      (hyhird
                                        {:opts {:file_types [:markdown :Avante]}
                                         :ft [:markdown :Avante]}
                                        :MeanderingProgrammer/render-markdown.nvim)]
                       :build :make
                       :cond use-avante
                       :mod :avante
                       :lazy false}
  :olimorris/codecompanion.nvim {:cond use-companion
                                 :dependencies [:stevearc/dressing.nvim
                                                :echasnovski/mini.nvim]
                                 :mod :companion}  

                                      
  :stevearc/oil.nvim {:config (fn []
                                ((. (require :oil) :setup) {})
                                (vim.keymap.set :n "-"
                                                :<cmd>Oil<cr>))}
  :rafamadriz/friendly-snippets {:config (fn [])}
  :garymjr/nvim-snippets {:opts {:friendly_snippets true}}
  :folke/noice.nvim {:cond (= (os.getenv :NO_NOICE) nil)
                     :config (simple-setup
                               :noice
                               {:presets {:command_palette true
                                          :long_message_to_split true}
                                :views {:mini {:timeout 5000
                                               :focusable true}}
                                :lsp {:signature {:enabled false}
                                      :progress {:enabled false}}})}
  :dfendr/clipboard-image.nvim {})


 
(require :magic.face)
(require :magic.project-scripts)
(require :magic.bigfile)
(require :magic.cmds)
(require :magic.hack.mini)

;; set XDG_CACHE_HOME back to ~/.cache to make terminal emulator
;; works well.
(vim.cmd "let $XDG_CACHE_HOME=expand('~/.cache/')")
(vim.cmd "set title")
(fn set-title []
  (let [title (.. "code " (vim.fn.getcwd))]
    (vim.api.nvim_set_option :titlestring title)))
(set-title)
