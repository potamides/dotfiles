--[[
Helper functions for setting up lsp servers in ftplugins. See
https://github.com/neovim/nvim-lspconfig/issues/970 for details.
--]]

local lspconfig = require("lspconfig")

local lspsetup = {mt = {}}

function lspsetup.setup(server, config)
  if server ~= nil and not server.manager then
    server.setup(config)
    if server.autostart then
      server.manager.try_add_wrapper()
    end
  end
end

function lspsetup.mt.__index(self, key)
  return {setup = function(config) self.setup(lspconfig[key], config) end}
end

return setmetatable(lspsetup, lspsetup.mt)
