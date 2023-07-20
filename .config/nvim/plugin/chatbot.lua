--[[
  Integrates a chatbot into neovim. Realized as a small wrapper around
  https://github.com/kharvd/gpt-cli. Can be invoked using `:Chat`.
]]
local chatterm = require("term").instance()

vim.api.nvim_create_user_command("Chat", function(tbl)
  if vim.fn.executable("gpt") == 1 then
    chatterm:open{
      cmd = {"gpt", unpack(tbl.fargs)},
      opts={
        env={
          -- use ansi colors (looks better with vim colorscheme)
          COLORTERM="standard",
          TERM="xterm-16color"
        }
      }
    }
  else
    vim.notify(
      "gpt-cli not installed. Get it here: https://github.com/kharvd/gpt-cli",
      vim.log.levels.ERROR
    )
  end
  end, {nargs = "*"}
)
