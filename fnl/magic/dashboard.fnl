(module magic.dashboard
  {autoload {nvim aniseed.nvim
             a aniseed.core
             util magic.util}})

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

(defn- render-dashboard []
  (let [buf (vim.api.nvim_create_buf false true)
        win (vim.api.nvim_get_current_win)
        win-width (vim.api.nvim_win_get_width win)
        win-height (vim.api.nvim_win_get_height win)
        cwd (vim.fn.getcwd)
        files (get-recent-files 10)
        ;; 头像路径
        avatar-path "/home/yj/.config/code/avatar.jpeg"]
    
    (vim.api.nvim_win_set_buf win buf)
    
    (let [lines []
          ;; 布局参数
          img-h 10
          img-w 20
          content-w 40 ;; 假设内容区域宽度
          left-padding (math.max 0 (math.floor (/ (- win-width content-w) 2)))
          top-padding (math.max 0 (math.floor (/ (- win-height 26) 2)))
          indent (string.rep " " left-padding)]
      
      ;; 1. 顶部填充
      (for [i 1 top-padding] (table.insert lines ""))
      
      ;; 2. 图片占位 (12行)
      (for [i 1 (+ img-h 2)] (table.insert lines ""))
      
      ;; 3. 项目路径 (居中显示)
      (let [project-str (.. "󰚝  " cwd)
            p-pad (math.max 0 (math.floor (/ (- win-width (vim.fn.strdisplaywidth project-str)) 2)))]
        (table.insert lines (.. (string.rep " " p-pad) project-str)))
      (table.insert lines "")
      
      ;; 4. 最近文件列表 (块对齐)
      (table.insert lines (.. indent "󰈚  Recent Files:"))
      (if (> (length files) 0)
          (each [i file (ipairs files)]
            (let [short-path (file:sub (+ (length cwd) 2))
                  display-text (string.format "   [%d] %s" i short-path)]
              (table.insert lines (.. indent display-text))))
          (table.insert lines (.. indent "   No recent files here.")))
      
      (table.insert lines "")
      
      ;; 5. 快捷功能 (块对齐)
      (table.insert lines (.. indent "󱁤  Actions:"))
      (let [shortcuts [["f" "Find Files"]
                       ["h" "Frecency Search"]
                       ["e" "New File"]
                       ["q" "Quit"]]]
        (each [_ [key desc] (ipairs shortcuts)]
          (table.insert lines (.. indent (string.format "   [%s] %s" key desc)))))

      (vim.api.nvim_buf_set_lines buf 0 -1 false lines)
      
      ;; 6. 应用高亮 (修复索引错误)
      (each [i content (ipairs lines)]
        (let [row (- i 1)]
          (if (content:find "──")
              (vim.api.nvim_buf_add_highlight buf -1 :Comment row 0 -1)
              (let [idx (content:find "%[")]
                (when idx
                  (vim.api.nvim_buf_add_highlight buf -1 :Directory row (- (+ left-padding idx) 1) (+ left-padding idx 2))))
              (or (content:find "󰈚") (content:find "󱁤"))
              (vim.api.nvim_buf_add_highlight buf -1 :Keyword row 0 -1))))

      ;; 7. Buffer 配置
      (set vim.bo.modifiable false)
      (set vim.bo.buftype :nofile)
      (set vim.bo.filetype :dashboard)
      (set vim.bo.bufhidden :wipe)
      (set vim.wo.number false)
      (set vim.wo.relativenumber false)
      (set vim.wo.list false)
      (set vim.wo.fillchars "eob: ")

      ;; 8. 渲染图片
      (when (util.exists? avatar-path)
        (vim.defer_fn
          (fn []
            (let [image (require :image)
                  instance (image.from_file
                             avatar-path
                             {:window win
                              :buffer buf
                              :x (math.floor (/ (- win-width img-w) 2))
                              :y (+ top-padding 1)
                              :width img-w
                              :height img-h})]
              (when instance (instance:render))))
          50))

      ;; 9. 快捷键映射
      (let [map-opts {:buffer buf :nowait true :silent true}]
        (each [i file (ipairs files)]
          (vim.keymap.set :n (tostring i) #(open-file file) map-opts))
        (vim.keymap.set :n :f #(vim.cmd "Telescope find_files") map-opts)
        (vim.keymap.set :n :h #(vim.cmd "Telescope frecency workspace=CWD") map-opts)
        (vim.keymap.set :n :e #(vim.cmd "enew") map-opts)
        (vim.keymap.set :n :q #(vim.cmd "quit") map-opts)))))

(defn setup []
  (vim.api.nvim_create_autocmd
    :VimEnter
    {:callback (fn []
                 (when (and (= (vim.fn.argc) 0)
                            (= (vim.fn.line2byte (vim.fn.line "$")) -1)
                            (= (vim.api.nvim_buf_get_name 0) ""))
                   (render-dashboard)))}))
