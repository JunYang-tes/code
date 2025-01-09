(module magic.model
  {autoload {nvim aniseed.nvim
             a aniseed.core}})


(defn load_model []
  (let [file (io.open (.. (os.getenv "HOME") "/.config/.avante_model") "r")]
    (if file
      (do
        (var model (file:read "*l"))
        (print model)
        (file:close)
        model))))

(var current_model (or
                    (load_model)
                    (os.getenv :ANVATE_OPENAI_MODEL)))

(local on_change [])

(defn save_model [model]
  (when (not= model current_model)
    (set current_model model)
    (each [_ f (ipairs on_change)]
      (pcall f))

    (let [file (io.open (.. (os.getenv "HOME") "/.config/.avante_model") "w")]
      (if file
        (do
          (file:write model)
          (file:close))))))

(defn add_on_change [f] (table.insert on_change f))

(defn get_model [] current_model)
