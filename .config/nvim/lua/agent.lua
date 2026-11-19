--[[
  Small wrapper for cli agents.
--]]
local term = require("term")

local agent = {
  opts = {},
  instance = term.instance(true),
  timer = vim.uv.new_timer(),
  timeout = 1000
}

-- map normal mode keys to terminal mode actions
function agent.ntmap(key, command)
  vim.keymap.set('n', key, function()
    local macro = vim.keycode('i' .. command .. '<C-\\><C-n>')
    vim.api.nvim_feedkeys(macro, 'nt', false)
  end)
end

function agent:launch(cmd, cwd)
  self.instance:open{cmd = cmd, opts = {
    cwd = cwd or self.opts.cwd, on_stdout=agent.watch
  }}

  local opts = {buffer = self.instance.termbuf, noremap = true, silent = true}
  for _, lhs in pairs{"q", "<esc>", "<S-esc>"} do
    vim.keymap.set("n", lhs, function() self.instance:close() end, opts)
  end
  vim.keymap.set("t", "<S-esc>", vim.cmd.stopinsert, opts)

  agent.ntmap('<C-f>', '<PageDown>')
  agent.ntmap('<C-b>', '<PageUp>')
  agent.ntmap('<C-e>', '<ScrollWheelDown>')
  agent.ntmap('<C-y>', '<ScrollWheelUp>')
end

function agent.watch()
  if agent.timer:get_due_in() == 0 then
    vim.cmd.checktime{mods = {silent = true, emsg_silent = true}}
    agent.timer:start(agent.timeout, 0, function() end)
  end
end

function agent.send()
  return agent.instance:send()
end

return agent
