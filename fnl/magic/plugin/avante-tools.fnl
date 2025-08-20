(module magic.plugin.avante-tools {autoload {nvim aniseed.nvim
                                             util magic.util}})
(local openai (require :avante.providers.openai))

(util.monkey-patch
  openai :parse_response
  (fn [self ctx data_stream a opts]
    (local state {:buffer ""
                  :in_call false})
    (openai self
            ctx data_stream a (vim.tbl_deep_extend 
                                :force
                                opts
                                {:on_chunk 
                                 (fn [chunk]
                                   (fn in_call []
                                     (let [lines (vim.split chunk "\n" {:trimempty true})]
                                       (each [_ line (ipairs lines)]
                                         (if (= line "```")
                                           (do
                                             (tset state :in_call false))
                                           (do
                                             (tset state :buffer (.. state.buffer line)))))))
                                   (fn waiting_call []
                                     (let [lines (vim.split chunk "\n" {:trimempty true})
                                           r (accumulate [r {:in_call false
                                                             :before_call ""
                                                             :call ""}
                                                          _ line (ipairs lines)]
                                               (match [r.in_call line]
                                                 [false "```call"] (do (tset r :in_call true))
                                                 [false _] (do (tset r :before_call (.. r.before_call line)))
                                                 [true "```"] (do 
                                                                (opts.on_chunk r.before_call)
                                                                (opts.on_stop
                                                                  {:reason :tool_use
                                                                   :tool_use_list ctx.tool_use_list
                                                                   :usage (vim.json.decode r.call)})
                                                                (tset r :in_call false)
                                                                (tset r :before_call "")
                                                                (tset r :call ""))
                                                          
                                                 [true _] (tset r :call (.. r.call "\n" line))))]
                                       (if r.in_call
                                         (do
                                           (tset state :in_call true)
                                           (tset state :buffer r.call))
                                         (not= "" r.before_call) (opts.on_chunk r.before_call))))
                                   (if (state.in_call)
                                     (in_call)
                                     (waiting_call)))}))))
(util.monkey-patch 
  openai :parse_curl_args 
  (fn [prompt_opts]
    (let [ret (openai self prompt_opts)]
      (when prompt_opts.tools_not_supported
        (table.insert 
          ret.body.messages
          {:role :assistant
           :content (table.concat  
                      ["You can use the following fuctions when needed\n"
                       "```json"
                       (vim.json.encode ret.body.tools)
                       "```"
                       "When you need to call a function, please generate a json block use the following format\n"
                       "```call"
                       (vim.json.encode {:id "<you fill this>"
                                         :type :function
                                         :function {:name "<you fill this>"
                                                    :arguments "<you fill this>"}})
                       "```"

                       "For example:"
                       "You received the following functions and the user ask you to create a new file\n"
                       "```json"
                       (vim.json.encode 
                         [{:type :function
                           :function {:name :create_file
                                      :description "Create a new file"
                                      :parameters {:type :object
                                                   :properties {:rel_path {:type :sting
                                                                           :description "Relative path to the file"}}}}}])
                                      
                       "```"
                       "You should response:"
                       "```call"
                       (vim.json.encode
                         [{:id "1"
                           :type :function
                           :function {:name :create_file
                                      :arguments {:rel_path "test.txt"}}}])
                       "```"
                       "---"]
                       
                      "\n")})

                        
           
        (tset ret :body :tools nil))
      ret)))

