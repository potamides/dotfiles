--[[
  Set some filetype-specific options.
--]]

if not vim.b.did_user_ftplugin then
  -- auto insert current comment with 'o' or 'O'
  vim.opt_local.formatoptions:remove("o")
  vim.b.did_user_ftplugin = true
end
