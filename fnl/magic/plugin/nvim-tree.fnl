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
      {:view {:mappings {:list [
                                {:key :h
                                 :action :close_node}
                                {:key [:o :<cr>]
                                 :action :change_root
                                 :desc "Enter director or open file"
                                 :action_cb change_root_to_node}
                                {:key :e
                                 :action :edit
                                 :desc "Edit in vertical splited"
                                 :action_cb api.node.open.vertical}
                                {:key :l
                                 :action :edit}
                                ]}}})))
