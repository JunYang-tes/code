(module magic.dashboard
  {autoload {nvim aniseed.nvim
             a aniseed.core
             util magic.util}})

;; 保存图片实例和配置
(var image-instance nil)
(var image-config nil)
(var dashboard-buf nil)
(var autocmd-ids [])

(defn- is-floating-window? [win]
  (when (and win (>= win 0))
    (let [config (vim.api.nvim_win_get_config win)]
      (and config.relative (not= config.relative "")))))

(defn- hide-image []
  (when image-instance
    (image-instance:clear)
    (set image-instance nil)))

(defn- show-image []
  (when (and image-config (not image-instance))
    (let [image (require :image)
          instance (image.from_file
                     image-config.path
                     (a.merge image-config.opts {:x image-config.x
                                                  :y image-config.y
                                                  :width image-config.w
                                                  :height image-config.h}))]
      (when instance
        (set image-instance instance)
        (instance:render)))))

(defn- get-recent-files [limit]
  (let [cwd (vim.fn.getcwd)
        files []]
    (each [_ file (ipairs (or vim.v.oldfiles []))]
      (when (and (< (length files) limit)
                 (file:find cwd 1 true)
                 (util.exists? file))
        (table.insert files file)))
    files))

(defn- open-file [file]
  (vim.cmd (.. "edit " file)))

(defn- cleanup-autocmd []
  (each [_ id (ipairs autocmd-ids)]
    (vim.api.nvim_del_autocmd id))
  (set autocmd-ids []))

(defn- render-dashboard []
  (let [buf (vim.api.nvim_create_buf false true)
        win (vim.api.nvim_get_current_win)
        ;; 获取窗口总宽度和高度
        total-width (vim.api.nvim_win_get_width win)
        win-height (vim.api.nvim_win_get_height win)
        ;; 获取装饰栏宽度 (signcolumn, foldcolumn, etc.)
        win-info (. (vim.fn.getwininfo win) 1)
        text-off (or win-info.textoff 0)
        ;; 实际可用的文本宽度
        win-width (- total-width text-off)
        
        cwd (vim.fn.getcwd)
        files (get-recent-files 10)
        avatar-path (util.get-path "avatar.jpeg")]
    
    (vim.api.nvim_win_set_buf win buf)
    
    (let [lines []
          ;; 布局参数
          img-h 10
          img-w 22
          content-w 50
          left-padding (math.max 0 (math.floor (/ (- win-width content-w) 2)))
          top-padding (math.max 0 (math.floor (/ (- win-height 26) 2)))
          indent (string.rep " " left-padding)
          ;; 填充空格，宽度为可用宽度，避免换行
          empty-line (string.rep " " win-width)]
      
      ;; 1. 顶部填充
      (for [i 1 top-padding] (table.insert lines ""))
      
      ;; 2. 图片占位 (填充空格)
      (for [i 1 (+ img-h 2)] (table.insert lines empty-line))
      
      ;; 3. 项目路径
      (table.insert lines (.. indent "󰚝  Project: " cwd))
      (table.insert lines "")
      
      ;; 4. 最近文件列表
      (table.insert lines (.. indent "󰈚  Recent Files"))
      (if (> (length files) 0)
          (each [i file (ipairs files)]
            (let [short-path (file:sub (+ (length cwd) 2))
                  ;; 使用 0-9 编号
                  display-text (string.format "   [%d] %s" (- i 1) short-path)]
              (table.insert lines (.. indent display-text))))
          (table.insert lines (.. indent "   No recent files here.")))
      
      (table.insert lines "")
      
      ;; 5. 快捷功能
      (table.insert lines (.. indent "󱁤  Actions"))
      (let [shortcuts [["f" "Find Files"]
                       ["h" "Frecency Search"]
                       ["e" "New File"]
                       ["q" "Quit"]]]
        (each [_ [key desc] (ipairs shortcuts)]
          (table.insert lines (.. indent (string.format "   [%s] %s" key desc)))))

      (vim.api.nvim_buf_set_lines buf 0 -1 false lines)
      
      ;; 6. 应用高亮
      (each [i content (ipairs lines)]
        (let [row (- i 1)]
          (let [idx (content:find "%[")]
            (when idx
              (vim.api.nvim_buf_add_highlight buf -1 :Directory row (- idx 1) (+ idx 2))))
          (if (or (content:find "󰈚") (content:find "󱁤") (content:find "󰚝"))
              (vim.api.nvim_buf_add_highlight buf -1 :Keyword row 0 -1))))

      ;; 7. Buffer 配置
      (set vim.bo.modifiable false)
      (set vim.bo.buftype :nofile)
      (set vim.bo.filetype :dashboard)
      (set vim.bo.bufhidden :wipe)

      ;; 保存 dashboard buffer 并设置清理
      (set dashboard-buf buf)
      (table.insert autocmd-ids
        (vim.api.nvim_create_autocmd
          :BufWipeout
          {:buffer buf
           :callback (fn []
                      (hide-image)
                      (set image-config nil)
                      (set dashboard-buf nil)
                      (cleanup-autocmd))}))
      (set vim.wo.number false)
      (set vim.wo.relativenumber false)
      (set vim.wo.list false)
      (set vim.wo.fillchars "eob: ")
      (set vim.wo.wrap false) ;; 强制关闭换行以防万一

      ;; 8. 渲染图片
      (when (util.exists? avatar-path)
        (let [curr-total-width (vim.api.nvim_win_get_width win)
              curr-win-info (. (vim.fn.getwininfo win) 1)
              curr-usable-width (- curr-total-width (or curr-win-info.textoff 0))
              img-x (math.floor (/ (- curr-usable-width img-w) 2))]
          ;; 保存图片配置
          (set image-config {:path avatar-path
                              :opts {:window win
                                     :buffer buf}
                              :x img-x
                              :y (+ top-padding 1)
                              :w img-w
                              :h img-h})
          (vim.defer_fn
            (fn []
              (show-image))
            100)))

      ;; 9. 快捷键映射
      (let [map-opts {:buffer buf :nowait true :silent true}]
        (each [i file (ipairs files)]
          (vim.keymap.set :n (tostring (- i 1)) #(open-file file) map-opts))
        (vim.keymap.set :n :f #(vim.cmd "Telescope find_files") map-opts)
        (vim.keymap.set :n :h #(vim.cmd "Telescope frecency workspace=CWD") map-opts)
        (vim.keymap.set :n :e #(vim.cmd "enew") map-opts)
        (vim.keymap.set :n :q #(vim.cmd "quit") map-opts)))))

(defn setup []
  ;; 清理旧的 autocmd
  (cleanup-autocmd)

  ;; 监听浮动窗口切换
  (table.insert autocmd-ids
    (vim.api.nvim_create_autocmd
      :WinEnter
      {:callback (fn []
                   (when (and dashboard-buf (is-floating-window? 0))
                     (hide-image)))}))

  (table.insert autocmd-ids
    (vim.api.nvim_create_autocmd
      :WinLeave
      {:callback (fn []
                   (when dashboard-buf
                     (let [next-win (vim.fn.winnr "#")
                           next-win-id (vim.fn.win_getid next-win)]
                       (when (and image-config
                                   (not (is-floating-window? next-win-id)))
                         (show-image)))))}))

  (table.insert autocmd-ids
    (vim.api.nvim_create_autocmd
      :WinClosed
      {:callback (fn []
                   (when (and dashboard-buf image-config
                              (not (is-floating-window? 0)))
                     (show-image)))}))

  ;; Dashboard 启动
  (vim.api.nvim_create_autocmd
    :VimEnter
    {:callback (fn []
                 (when (and (= (vim.fn.argc) 0)
                            (= (vim.fn.line2byte (vim.fn.line "$")) -1)
                            (= (vim.api.nvim_buf_get_name 0) ""))
                   (render-dashboard)))}))
