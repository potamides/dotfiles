--[[
  Prevent netrw from mapping bookmarks to 'gb' which would conflict with
  another mapping.
--]]
if not vim.g.loaded_netrw_plugin_extensions then
  vim.api.nvim_set_keymap('n', '<nop>', "<Plug>NetrwBookHistHandler_gb", {silent = true, nowait = true})
  vim.g.loaded_netrw_plugin_extensions = true
end
