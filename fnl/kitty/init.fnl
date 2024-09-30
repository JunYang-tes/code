(module kitty.init
  {autoload {plugin magic.plugin
             nvim aniseed.nvim}})
(vim.loader.enable)

(macro simple-setup [plugin opts]
  `(fn []
    (let [{:setup setup#} (require ,plugin)]
      (setup# ,opts))))

(plugin.use
  :Olical/aniseed {}
  ; :folke/noice.nvim {:config (simple-setup
  ;                              :noice
  ;                              {:presets {:command_palette true
  ;                                         :long_message_to_split true}
  ;                               :views {:mini {:timeout 5000
  ;                                              :focusable true}}
  ;                               :lsp {:signature {:enabled false}
  ;                                     :progress {:enabled false}}})}
  :s1n7ax/nvim-window-picker {:version "2.*"
                              :event :VeryLazy
                              :window :window-picker
                              :config {:hint :floating-big-letter
                                       :filter_func (fn [ids]
                                                      ids)}}
  ;; Theme
  :folke/tokyonight.nvim {
                          :opts {}
                          :lazy false
                          :priority 1000} 
  :mikesmithgh/kitty-scrollback.nvim {:enabled true
                                      :lazy true
                                      :event ["User KittyScrollbackLaunch"]
                                      :cmd [:KittyScrollbackGenerateKittens
                                            :KittyScrollbackCheckHealth]
                                      :config (fn []
                                                (let [kitty-scrollback (require :kitty-scrollback)]
                                                  (kitty-scrollback.setup)))})
                                      
  
(require :magic.face)
