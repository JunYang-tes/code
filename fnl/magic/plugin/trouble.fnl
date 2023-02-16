(let [(ok? t) (pcall #(require :trouble))]
  (when ok?
    (t.setup)))
