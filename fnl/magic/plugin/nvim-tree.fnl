(module magic.plugin.nvim-tree
  {autoload {util magic.util
             nvim aniseed.nvim
             image magic.plugin.image}})

(let [(ok? nvim-tree) (pcall #(require :nvim-tree))
      (_ api) (pcall #(require :nvim-tree.api))
      (_ marks) (pcall #(require :nvim-tree.marks))
      nui_popup (require "nui.popup")
      trash (fn []
              (let [nodes (marks.get_marks)
                    node (api.tree.get_node_under_cursor)]
                (if (and nodes
                         (> (length nodes) 0))
                  (api.marks.bulk.trash)
                  (api.fs.trash node))))
      change_root_to_node (fn []
                            (let [node (api.tree.get_node_under_cursor)]
                              (if (not= nil node.nodes)
                                  (api.tree.change_root_to_node node)))
                            (api.node.open.edit node))
      preview (fn []
                (let [node (api.tree.get_node_under_cursor)
                      event (require :nui.utils.autocmd)
                      path node.absolute_path
                      [line column] (vim.api.nvim_win_get_cursor 0)]
                  (when (= node.type :file)
                    (let [
                          popup (nui_popup
                                  {:relative "editor"
                                   :position {:row line :col column}
                                   :enter true
                                   :size :30%
                                   :border {:style :rounded}
                                   :anchor "NE"})]
                      (popup:mount)
                      (vim.defer_fn
                        (fn []
                          (image.preview popup.winid popup.bufnr path))
                        50)
                      (vim.defer_fn
                        (fn []
                          (var ns_id nil)
                          (set ns_id
                               (vim.on_key
                                 (fn []
                                   (popup:hide)
                                   (popup:unmount)
                                   (vim.on_key nil ns_id)))))
                        100)))))]
  (when ok?
    (nvim-tree.setup
      {:on_attach (fn [bufnr]
                    (let [keymap (fn [mode lhs rhs help]
                                   (vim.keymap.set mode lhs rhs {:buffer bufnr
                                                                 :desc help}))]
                      (keymap :n :K preview)
                      (keymap :n "[c" api.node.navigate.git.prev)
                      (keymap :n "]c" api.node.navigate.git.next)
                      (keymap :n :<space> api.marks.toggle :Select)
                      (keymap :n :c api.fs.copy.node :Copy)
                      (keymap :n :? api.tree.toggle_help :Help)
                      (keymap :n :a api.fs.create "Create file")
                      (keymap :n :x api.fs.cut :Cut)
                      (keymap :n :d trash "Delete file(s)")
                      (keymap :n :p api.fs.paste :Paste)
                      (keymap :n :R api.tree.reload :Reload)
                      (keymap :n :r api.fs.rename :Rename)
                      (keymap :n :q api.tree.close :Close)
                      (keymap :n :l api.node.open.edit :Edit)
                      (keymap :n :h api.node.navigate.parent_close "Close parent directory")
                      (keymap :n :> api.node.navigate.sibling.next "Navigate to next sibling")
                      (keymap :n :< api.node.navigate.sibling.prev "Navigate to previous sibling")
                      (keymap :n :- api.tree.change_root_to_parent "Change root to parent")
                      (keymap :n :<cr> change_root_to_node "Change root to current director")
                      (keymap :n :e api.node.open.vertical "Edit vertically")))
       :git {:ignore false}
       :update_focused_file {:enable true
                             :ignore_list [:node_modules]
                             :update_cwd false}
       :filters {
                 :dotfiles false
                 :git_clean false}})))
