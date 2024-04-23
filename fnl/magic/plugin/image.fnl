(module magic.plugin.image
  {autoload {nvim aniseed.nvim
             core aniseed.core}})

(local image (require :image))
(image.setup
  {:integrations {:markdown {:enabled false}}}
  {:hijack_file_patterns [:*.png :*.jpg :*.jpeg :*.gif :*.webp]})

(defn preview [winid bufnr path]
  (let [instance (image.from_file
                   path
                   {
                    :x 0
                    :y 0
                    :window winid})]
    (when instance
      (instance:render))))
