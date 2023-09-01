--[[
  Integrates a chatbot into neovim. Realized as a small wrapper around
  https://github.com/kharvd/gpt-cli. Can be invoked using `:Chat`.
]]
local chatterm = require("term").instance()

vim.api.nvim_create_user_command("Chat", function(tbl)
  if vim.fn.executable("gpt") == 1 then
    chatterm:open{
      -- we use neovim for syntax highlighting, so disable everything else
      cmd = {"gpt", "--no_markdown", unpack(tbl.fargs)},
      opts = {env = {NO_COLOR = "true"}}
    }

    -- set syntax to markdown and enable concealing
    vim.opt_local.syntax = "markdown"
    vim.opt_local.concealcursor = 'nvc'
    vim.opt_local.conceallevel = 2

    -- add custom syntax highlighting for the prompt
    local group, matchgroup = "GPTPrompt", "matchgroup=markdownBlockquote"
    vim.cmd.syntax{args = {"region", group, matchgroup, [[start=">\s"]], [[end="$"]]}}
    vim.cmd.syntax{args = {"region", group, matchgroup, 'start="multiline>"',  [[end="^\(\s\|\s\{11}\)\@!"]]}}
    vim.cmd.syntax{args = {"clear", "markdownError", "markdownEscape", "luaError", "luaParenError"}}
    vim.api.nvim_set_hl(0, group, {link = "String", default=true})
  else
    vim.notify(
      "gpt-cli not installed. Get it here: https://github.com/kharvd/gpt-cli",
      vim.log.levels.ERROR
    )
  end
  end, {nargs = "*"}
)
