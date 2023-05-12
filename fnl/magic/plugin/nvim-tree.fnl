(module magic.plugin.nvim-tree
  {autoload {util magic.util
             nvim aniseed.nvim}})

(let [(ok? nvim-tree) (pcall #(require :nvim-tree))
      (_ api) (pcall #(require :nvim-tree.api))
      change_root_to_node (fn [] 
                            (let [node (api.tree.get_node_under_cursor)]
                              (if (not= nil node.nodes)
                                  (api.tree.change_root_to_node node)))
                                  (api.node.open.edit node))]
  (when ok?
    (nvim-tree.setup
      {:on_attach (fn [bufnr]
                    (let [keymap (fn [mode lhs rhs ]
                                   (vim.keymap.set mode lhs rhs {:buffer bufnr}))]
                      (keymap :n "[c" api.node.navigate.git.prev)
                      (keymap :n "]c" api.node.navigate.git.next)
                      (keymap :n :c api.fs.copy.node)
                      (keymap :n :g? api.tree.toggle_help)
                      (keymap :n :a api.fs.create)
                      (keymap :n :x api.fs.cut)
                      (keymap :n :d api.fs.trash)
                      (keymap :n :p api.fs.paste)
                      (keymap :n :R api.tree.reload)
                      (keymap :n :r api.fs.rename)
                      (keymap :n :q api.tree.close)
                      (keymap :n :l api.node.open.edit)
                      (keymap :n :h api.node.navigate.parent_close)
                      (keymap :n :> api.node.navigate.sibling.next)
                      (keymap :n :< api.node.navigate.sibling.prev)
                      (keymap :n :- api.tree.change_root_to_parent)
                      (keymap :n :<cr> change_root_to_node)
                      (keymap :n :e api.node.open.vertical)))
       :git {:ignore false}
       :filters {
                 :dotfiles false
                 :git_clean false
                 }})))
       ; :view {:mappings {:list [
       ;                          {:key :h
       ;                           :action :close_node}
       ;                          {:key [:o :<cr>]
       ;                           :action :change_root
       ;                           :desc "Enter director or open file"
       ;                           :action_cb change_root_to_node}
       ;                          {:key :e
       ;                           :action :edit
       ;                           :desc "Edit in vertical splited"
       ;                           :action_cb api.node.open.vertical}
       ;                          {:key :l
       ;                           :action :edit}
       ;                          ]}}})))
