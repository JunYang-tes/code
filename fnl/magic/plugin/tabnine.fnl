(module magic.plugin.tabnine)
((. (require :tabnine) :setup)
 {:disable_auto_comment true
  :accept_keymap "<Tab>"
  :dismiss_keymap "<C-]>"
  :debounce_ms 800
  :suggestion_color {:gui :#808080}
  :exclude_filetypes {:fennel :TelescopePrompt}})
