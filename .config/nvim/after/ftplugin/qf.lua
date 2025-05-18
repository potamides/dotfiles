--[[
  Remove the quickfix window from the buffer list.
]]

if not vim.b.did_user_ftplugin then
  vim.opt_local.buflisted = false
  vim.b.did_user_ftplugin = true
end
