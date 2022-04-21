--[[
  Map bookmark handler to 'b and `b in netrw windows.
--]]

if not vim.b.did_user_ftplugin then
  vim.keymap.set("n", "'b", "<Plug>NetrwBookHistHandler_gb", {silent = true, nowait = true, buffer = true})
  vim.keymap.set("n", "`b", "<Plug>NetrwBookHistHandler_gb", {silent = true, nowait = true, buffer = true})
  vim.b.did_user_ftplugin = true
end
