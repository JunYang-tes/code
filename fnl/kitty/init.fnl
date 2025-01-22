(module kitty.init
  {autoload {plugin magic.plugin
             nvim aniseed.nvim}})
(vim.loader.enable)
(fn hyhird [tbl ...]
  (each [i v (ipairs [...])]
    (tset tbl i v))
  tbl)

(macro simple-setup [plugin opts]
  `(fn []
    (let [{:setup setup#} (require ,plugin)]
      (setup# ,opts))))

(plugin.use
  :Olical/aniseed {}
  :tpope/vim-surround {}
  :folke/flash.nvim {:keys [
                            (hyhird {:mode [:n :o :x]} :s #((-> :flash
                                                               require
                                                               (. :jump))))]}
  :JunYang-tes/nvim-window-picker {:version "2.*"
                                   :event :VeryLazy
                                   :window :window-picker
                                   :config {:hint :floating-letter
                                            :filter_func (fn [ids]
                                                           ids)}}
  ;; Theme
  :folke/tokyonight.nvim {
                          :opts {}
                          :lazy false
                          :priority 1000} 
  :mikesmithgh/kitty-scrollback.nvim {:enabled true
                                      :lazy false
                                      :cmd [:KittyScrollbackGenerateKittens
                                            :KittyScrollbackCheckHealth]
                                      :config (fn []
                                                (let [kitty-scrollback (require :kitty-scrollback)]
                                                  (kitty-scrollback.setup)))})
                                      
  
(require :magic.face)
