local M = {
  "frankroeder/parrot.nvim",
  dependencies = { "ibhagwan/fzf-lua", "nvim-lua/plenary.nvim" },
  lazy = false,
}

local cmd_prefix = "Prt"

function M.config()
  require("parrot").setup({
    providers = {
      anthropic = {
        api_key = os.getenv("ANTHROPIC_API_KEY"),
      },
    },
    hooks = {
      Complete = function(prt, params)
        local template = [[
        I have the following code from {{filename}}:

        ```{{filetype}}
        {{selection}}
        ```

        Please finish the code above carefully and logically.
        Respond just with the snippet of code that should be inserted."
        ]]
        local agent = prt.get_command_agent()
        prt.Prompt(params, prt.ui.Target.append, nil, agent.model, template, agent.system_prompt, agent.provider)
      end,
      CompleteFullContext = function(prt, params)
        local template = [[
        I have the following code from {{filename}} and other realted files:

				```{{filetype}}
				{{multifilecontent}}
				```

				Please look at the following section specifically:
        ```{{filetype}}
        {{selection}}
        ```

        Please finish the code above carefully and logically.
        Respond just with the snippet of code that should be inserted."
        ]]
        local agent = prt.get_command_agent()
        prt.Prompt(params, prt.ui.Target.append, nil, agent.model, template, agent.system_prompt, agent.provider)
      end,
      Explain = function(prt, params)
        local template = [[
        Your task is to take the code snippet from {{filename}} and explain it with gradually increasing complexity.
        Break down the code's functionality, purpose, and key components.
        The goal is to help the reader understand what the code does and how it works.

        ```{{filetype}}
        {{selection}}
        ```

        Use the markdown format with codeblocks and inline code.
        Explanation of the code above:
        ]]
        local agent = prt.get_chat_agent()
        prt.logger.info("Explaining selection with agent: " .. agent.name)
        prt.Prompt(params, prt.ui.Target.new, nil, agent.model, template, agent.system_prompt, agent.provider)
      end,
      FixBugs = function(prt, params)
        local template = [[
        You are an expert in {{filetype}}.
        Fix bugs in the below code from {{filename}} carefully and logically:
        Your task is to analyze the provided {{filetype}} code snippet, identify
        any bugs or errors present, and provide a corrected version of the code
        that resolves these issues. Explain the problems you found in the
        original code and how your fixes address them. The corrected code should
        be functional, efficient, and adhere to best practices in
        {{filetype}} programming.

        ```{{filetype}}
        {{selection}}
        ```

        Fixed code:
        ]]
        local agent = prt.get_command_agent()
        prt.logger.info("Fixing bugs in selection with agent: " .. agent.name)
        prt.Prompt(params, prt.ui.Target.new, nil, agent.model, template, agent.system_prompt, agent.provider)
      end,
      Optimize = function(prt, params)
        local template = [[
        You are an expert in {{filetype}}.
        Your task is to analyze the provided {{filetype}} code snippet and
        suggest improvements to optimize its performance. Identify areas
        where the code can be made more efficient, faster, or less
        resource-intensive. Provide specific suggestions for optimization,
        along with explanations of how these changes can enhance the code's
        performance. The optimized code should maintain the same functionality
        as the original code while demonstrating improved efficiency.

        ```{{filetype}}
        {{selection}}
        ```

        Optimized code:
        ]]
        local agent = prt.get_command_agent()
        prt.logger.info("Optimizing selection with agent: " .. agent.name)
        prt.Prompt(params, prt.ui.Target.new, nil, agent.model, template, agent.system_prompt, agent.provider)
      end,
      UnitTests = function(prt, params)
        local template = [[
        I have the following code from {{filename}}:

        ```{{filetype}}
        {{selection}}
        ```

        Please respond by writing table driven unit tests for the code above.
        ]]
        local agent = prt.get_command_agent()
        prt.logger.info("Creating unit tests for selection with agent: " .. agent.name)
        prt.Prompt(params, prt.ui.Target.enew, nil, agent.model, template, agent.system_prompt, agent.provider)
      end,
      Debug = function(prt, params)
        local template = [[
        I want you to act as {{filetype}} expert.
        Review the following code, carefully examine it, and report potential
        bugs and edge cases alongside solutions to resolve them.
        Keep your explanation short and to the point:

        ```{{filetype}}
        {{selection}}
        ```
        ]]
        local agent = prt.get_chat_agent()
        prt.logger.info("Debugging selection with agent: " .. agent.name)
        prt.Prompt(params, prt.ui.Target.enew, nil, agent.model, template, agent.system_prompt, agent.provider)
      end,
    },
  })
end

function M.keys()
  local kmprfx = "<C-g>"
  local function kmopts(desc)
    return {
      noremap = true,
      silent = true,
      nowait = true,
      desc = desc,
    }
  end
  return {
    {
      kmprfx .. "c",
      "<cmd>" .. cmd_prefix .. "ChatNew<cr>",
      mode = { "n", "i" },
      kmopts("New Chat"),
    },
    {
      kmprfx .. "t",
      "<cmd>" .. cmd_prefix .. "ChatToggle<cr>",
      mode = { "n", "i" },
      kmopts("Toggle Popup Chat"),
    },
    {
      kmprfx .. "f",
      "<cmd>" .. cmd_prefix .. "ChatFinder<cr>",
      mode = { "n", "i" },
      kmopts("Chat Finder"),
    },
    {
      kmprfx .. "r",
      "<cmd>" .. cmd_prefix .. "Rewrite<cr>",
      mode = { "n", "i" },
      kmopts("Inline Rewrite"),
    },
    {
      kmprfx .. "a",
      "<cmd>" .. cmd_prefix .. "Append<cr>",
      mode = { "n", "i" },
      kmopts("Append"),
    },
    {
      kmprfx .. "o",
      "<cmd>" .. cmd_prefix .. "Prepend<cr>",
      mode = { "n", "i" },
      kmopts("Prepend"),
    },
    {
      kmprfx .. "c",
      ":<C-u>'<,'>" .. cmd_prefix .. "ChatNew<cr>",
      mode = { "v" },
      kmopts("Visual Chat New"),
    },
    {
      kmprfx .. "r",
      ":<C-u>'<,'>" .. cmd_prefix .. "Rewrite<cr>",
      mode = { "v" },
      kmopts("Visual Rewrite"),
    },
    {
      kmprfx .. "a",
      ":<C-u>'<,'>" .. cmd_prefix .. "Append<cr>",
      mode = { "v" },
      kmopts("Visual Append"),
    },
    {
      kmprfx .. "o",
      ":<C-u>'<,'>" .. cmd_prefix .. "Prepend<cr>",
      mode = { "v" },
      kmopts("Visual Prepend"),
    },
    {
      kmprfx .. "e",
      ":<C-u>'<,'>" .. cmd_prefix .. "Enew<cr>",
      mode = { "v" },
      kmopts("Visual Enew"),
    },
    {
      kmprfx .. "s",
      "<cmd>" .. cmd_prefix .. "Stop<cr>",
      mode = { "n", "i", "v", "x" },
      kmopts("Stop"),
    },
    {
      kmprfx .. "i",
      ":<C-u>'<,'>" .. cmd_prefix .. "Complete<cr>",
      mode = { "n", "i", "v", "x" },
      kmopts("Complete the visual selection"),
    },
    {
      kmprfx .. "x",
      "<cmd>" .. cmd_prefix .. "Context<cr>",
      mode = { "n" },
      kmopts("Open file with custom context"),
    },
    {
      kmprfx .. "n",
      "<cmd>" .. cmd_prefix .. "Agent<cr>",
      mode = { "n" },
      kmopts("Select agent"),
    },
    {
      kmprfx .. "p",
      "<cmd>" .. cmd_prefix .. "Provider<cr>",
      mode = { "n" },
      kmopts("Select provider"),
    },
    {
      kmprfx .. "q",
      "<cmd>" .. cmd_prefix .. "Ask<cr>",
      mode = { "n" },
      kmopts("Ask a question"),
    },
  }
end

return M
