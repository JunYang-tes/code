(module magic.plugin.image
  {autoload {nvim aniseed.nvim
             util magic.util
             core aniseed.core}})

(local image (require :image))
(local image-util (require :image.utils))
(image.setup
  {:integrations {:markdown {:enabled false}}}
  {:hijack_file_patterns [:*.png :*.jpg :*.jpeg :*.gif :*.webp]})

(util.monkey-patch
  image-util.magic
  :is_image
  (fn [_ _ path]
    (let [img-postfix [:%.png :%.ppm :%.tga :%.svg
                       :%.gif :%.jpg :%.jpeg :%.webp]]
      (core.some #(string.match path $1) img-postfix))))


(defn preview [winid bufnr path]
  (let [instance (image.from_file
                   path
                   {
                    :x 0
                    :y 0
                    :window winid})]
    (when instance
      (instance:render))))
