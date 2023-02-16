(module magic.plugin.telescope
  {autoload {nvim aniseed.nvim
             util magic.util}})

(let [(ok? telescope) (pcall #(require :telescope))]
  (when ok?
    (telescope.setup
      {:defaults
       {:vimgrep_arguments ["rg" "--color=never" "--no-heading"
                            "--with-filename" "--line-number" "--column"
                            "--smart-case" "--hidden" "--follow"
                            "-g" "!.git/"]
        :extensions {:recent_files {:only_cwd true}}}})

    (pcall #(telescope.load_extension :recent_files))))

