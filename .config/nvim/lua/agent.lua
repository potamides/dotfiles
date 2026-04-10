--[[
  Small wrapper for the claude code cli.
--]]
local term = require("term")

local agent = {
  command = {"claude"},
  opts = {},
  instance = term.instance(true)
}

function agent:launch(cwd)
  local command = vim.list_extend(vim.list_slice(self.command), self.opts)
  self.instance:open{cmd = command, opts = {cwd = cwd or self.opts.cwd}}

  local opts = {buffer = self.instance.termbuf, noremap = true, silent = true}
  for _, lhs in pairs{"q", "<esc>", "<S-esc>"} do
    vim.keymap.set("n", lhs, function() self.instance:close() end, opts)
  end
  vim.keymap.set("t", "<S-esc>", vim.cmd.stopinsert, opts)
end

function agent:specialize(args)
  local opts = {"--tools", "", "--strict-mcp-config", "--mcp-config", "", "--no-chrome"}
  opts.cwd = vim.fn.stdpath("run")
  args = args or {}

  if not args.isolate then
    opts = {}
  end

  for flag, value in pairs{["--model"] = args.model, ["--system-prompt"] = args.prompt} do
    if value then
      for _, opt in ipairs{flag, value} do
        table.insert(opts, opt)
      end
    end
  end

  return setmetatable({instance = term.instance(true), opts = opts}, {
    __index = agent,
    __newindex = function(_, k, v) agent[k] = v end
  })
end

function agent.send()
  return agent.instance:send()
end

return agent
