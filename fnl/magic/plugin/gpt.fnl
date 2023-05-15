(module magic.plugin.gpt
  {autoload {nvim aniseed.nvim}})

(let [(ok? gpt) (pcall require :chatgpt)]
  (when ok?
    (print :setup-gpt)
    (gpt.setup)))
