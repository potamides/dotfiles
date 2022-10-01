--[[
  Remove the quickfix window from the buffer list and close nvim when qf is
  last window.
]]
if not vim.b.did_user_ftplugin then
  vim.opt_local.buflisted = false
  vim.b.did_user_ftplugin = true
end
