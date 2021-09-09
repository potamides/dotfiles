--[[
  Configure formatoptions for writing "format=flowed" mails with mutt.
  (see http://www.mutt.org/doc/manual/#text-flowed)
--]]

if not vim.b.set_mail_format then
  vim.opt_local.formatoptions:append("w")
  vim.b.set_mail_format = true
end
