--[[
  LaTeX-specific options and mappings.
--]]

if not vim.b.did_user_ftplugin then
  -- in insert mode do not break a line which already was longer than 'textwidth'
  vim.opt_local.formatoptions:append{
    l = true,
  }

  vim.b.did_user_ftplugin = true
end
