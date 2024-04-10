; [{source}]
(module magic.bigfile
  {autoload {core aniseed.core}})

;; rust_analyzer 报告的diagnostics 包含了重复的内容。
;; 重复的内容来自rustc, 这里通过hack的方式过滤掉rustc
;; 的diagnostic 信息
(let [original vim.diagnostic.set]
  (fn set-diagnostics [ns buf diagnostics opt]
    (original
      ns buf (core.filter
              (fn [item]
                (not= item.source :rustc))
              diagnostics) opt))
  (tset vim :diagnostic :set set-diagnostics))
