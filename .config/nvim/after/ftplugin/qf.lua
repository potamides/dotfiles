--[[
  Remove the quickfix window from the buffer list, set its size and close
  term windows.
]]

if not vim.b.did_user_ftplugin then
  vim.opt_local.buflisted = false

  vim.b.did_user_ftplugin = true
end

-- do some window local things outside of the buffer guard
local term = require("term")

vim.opt_local.winheight = term.height
if vim.tbl_contains(vim.api.nvim_tabpage_list_wins(0), term.termwin) then
  term:close()
end
