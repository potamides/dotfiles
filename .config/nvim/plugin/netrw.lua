--[[
  Netrw quickfixes.
--]]

-- works around an annoying netrw bug (see https://github.com/vim/vim/issues/4738)
vim.api.nvim_set_keymap("n", "gx", "<cmd>call netrw#BrowseX(netrw#GX(), 0)<cr>", {noremap = true, silent = true})
-- Prevent netrw from mapping bookmarks to 'gb' which would conflict with another mapping.
vim.api.nvim_set_keymap('n', '<nop>', "<Plug>NetrwBookHistHandler_gb", {silent = true, nowait = true})
