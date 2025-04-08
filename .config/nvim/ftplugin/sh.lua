--[[
  Setup bash language server.
--]]

if not vim.b.did_user_ftplugin then
  require("lsputils").bashls.setup{}
end
