--[[
  Configure formatoptions for writing "format=flowed" mails with mutt.
  (see http://www.mutt.org/doc/manual/#text-flowed)
--]]

if not vim.b.did_user_ftplugin then
  vim.opt_local.formatoptions:append("w")
  vim.b.did_user_ftplugin = true
end
