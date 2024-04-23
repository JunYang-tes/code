(module magic.util
  {autoload {nvim aniseed.nvim
             a aniseed.core}})

(defn expand [path]
  (nvim.fn.expand path))

(defn glob [path]
  (nvim.fn.glob path true true true))

(defn exists? [path]
  (= (nvim.fn.filereadable path) 1))

(defn lua-file [path]
  (nvim.ex.luafile path))

(def config-path (nvim.fn.stdpath "config"))

(defn some [list predict]
  (each [ _ item (ipairs list)]
    (if (predict item)
      (lua "return true")))
  false)

(defn nnoremap [from to opts]
  (let [map-opts {:noremap true}
        to (.. ":" to "<cr>")]
    (if (a.get opts :local?)
      (nvim.buf_set_keymap 0 :n from to map-opts)
      (nvim.set_keymap :n from to map-opts))))

(defn noremap [from to opts]
  (let [map-opts {:noremap true}]
    (if (a.get opts :local?)
      (nvim.buf_set_keymap 0 :n from to map-opts)
      (nvim.set_keymap :n from to map-opts))))

(defn lnnoremap [from to]
  (nnoremap (.. "<leader>" from) to))

(defn is-a-big-file [buf max-size]
  (let [fname (vim.api.nvim_buf_get_name buf)
        max-size (or max-size 500)
        size (/ (vim.fn.getfsize fname) 1024)]
    (> size max-size)))

(defn has-long-line [bufnr max-length]
  (let [lines (vim.api.nvim_buf_get_lines bufnr 0 -1 false)
        max-length (or max-length 100000)]
    (some lines #(> (string.len $1) max-length))))
(defn monkey-patch [tbl fn-name f]
  (let [original (. tbl fn-name)]
    (tset tbl fn-name
          (fn [...]
            (f tbl original ...)))))
