--[[
  Small wrapper for cli agents.
--]]
local term = require("term")

local agent = {
  opts = {},
  instance = term.instance(true)
}

function agent:launch(cmd, cwd)
  self.instance:open{cmd = cmd, opts = {cwd = cwd or self.opts.cwd}}

  local opts = {buffer = self.instance.termbuf, noremap = true, silent = true}
  for _, lhs in pairs{"q", "<esc>", "<S-esc>"} do
    vim.keymap.set("n", lhs, function() self.instance:close() end, opts)
  end
  vim.keymap.set("t", "<S-esc>", vim.cmd.stopinsert, opts)
end

function agent.send()
  return agent.instance:send()
end

return agent
