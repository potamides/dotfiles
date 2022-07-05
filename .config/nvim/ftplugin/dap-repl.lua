--[[
  Remove the repl window from the buffer list and close nvim when repl is last
  window.
]]
if not vim.b.did_user_ftplugin then
  -- same behavior like quickfix window
  vim.cmd("runtime! ftplugin/qf.lua")
end
