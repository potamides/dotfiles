--[[
  Configure basedpyright which shares same config with pyright.
--]]
local config = assert(
  loadfile(vim.api.nvim_get_runtime_file("after/lsp/pyright.lua", false)[1])
)()

config.settings.basedpyright = config.settings.python

for name, func in pairs(config.commands or {}) do
  config.commands["based" .. name] = func
end

return config
