--[[
  Map bookmark handler to 'b and `b in netrw windows.
--]]

if not vim.b.did_user_ftplugin then
  vim.api.nvim_buf_set_keymap(0, "n", "'b", "<Plug>NetrwBookHistHandler_gb", {silent = true, nowait = true})
  vim.api.nvim_buf_set_keymap(0, "n", '`b', "<Plug>NetrwBookHistHandler_gb", {silent = true, nowait = true})
  vim.b.did_user_ftplugin = true
end
