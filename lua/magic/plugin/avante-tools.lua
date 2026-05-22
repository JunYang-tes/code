local util = require("magic.util")
local openai = require("avante.providers.openai")

util.monkey_patch(openai, "parse_response", function(self, ctx, data_stream, a, opts)
  local state = { buffer = "", in_call = false }

  openai(self, ctx, data_stream, a, vim.tbl_deep_extend("force", opts, {
    on_chunk = function(chunk)
      local function in_call()
        local lines = vim.split(chunk, "\n", { trimempty = true })
        for _, line in ipairs(lines) do
          if line == "```" then
            state.in_call = false
          else
            state.buffer = state.buffer .. line
          end
        end
      end

      local function waiting_call()
        local lines = vim.split(chunk, "\n", { trimempty = true })
        local r = { in_call = false, before_call = "", call = "" }
        for _, line in ipairs(lines) do
          if not r.in_call and line == "```call" then
            r.in_call = true
          elseif not r.in_call then
            r.before_call = r.before_call .. line
          elseif r.in_call and line == "```" then
            opts.on_chunk(r.before_call)
            opts.on_stop({
              reason = "tool_use",
              tool_use_list = ctx.tool_use_list,
              usage = vim.json.decode(r.call),
            })
            r.in_call = false
            r.before_call = ""
            r.call = ""
          elseif r.in_call then
            r.call = r.call .. "\n" .. line
          end
        end
        if r.in_call then
          state.in_call = true
          state.buffer = r.call
        elseif r.before_call ~= "" then
          opts.on_chunk(r.before_call)
        end
      end

      if state.in_call then
        in_call()
      else
        waiting_call()
      end
    end,
  }))
end)

util.monkey_patch(openai, "parse_curl_args", function(prompt_opts)
  local ret = openai(self, prompt_opts)
  if prompt_opts.tools_not_supported then
    table.insert(ret.body.messages, {
      role = "assistant",
      content = table.concat({
        "You can use the following fuctions when needed\n",
        "```json",
        vim.json.encode(ret.body.tools),
        "```",
        "When you need to call a function, please generate a json block use the following format\n",
        "```call",
        vim.json.encode({
          id = "<you fill this>",
          type = "function",
          function = { name = "<you fill this>", arguments = "<you fill this>" },
        }),
        "```",
        "",
        "For example:",
        "You received the following functions and the user ask you to create a new file\n",
        "```json",
        vim.json.encode({
          {
            type = "function",
            function = {
              name = "create_file",
              description = "Create a new file",
              parameters = {
                type = "object",
                properties = { rel_path = { type = "sting", description = "Relative path to the file" } },
              },
            },
          },
        }),
        "```",
        "You should response:",
        "```call",
        vim.json.encode({
          {
            id = "1",
            type = "function",
            function = { name = "create_file", arguments = { rel_path = "test.txt" } },
          },
        }),
        "```",
        "---",
      }, "\n"),
    })
    ret.body.tools = nil
  end
  return ret
end)
