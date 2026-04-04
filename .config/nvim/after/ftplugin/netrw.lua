--[[
  Change display of vertical bar in netrw windows.
--]]

if not vim.b.did_user_ftplugin then
  local winid = vim.api.nvim_get_current_win()

  -- change vertical bar from | to │ by (ab)using concealing
  vim.fn.matchadd("Conceal", [[\(^\([-+|] \)*\)\@<=| \@=]], nil, -1, {conceal = "│"})
  vim.wo[winid][0].winhighlight = "Conceal:netrwTreeBar"
  vim.wo[winid][0].conceallevel = 2
  vim.wo[winid][0].concealcursor = "nvic"
  vim.wo[winid][0].list = false -- in empty directories there is trailing whitespace

  -- make window-local matchadd behave more buffer-locally
  vim.api.nvim_create_autocmd("BufWinLeave", {
    buffer = 0,
    once = true,
    callback = function() vim.fn.clearmatches(winid) end,
  })

  vim.b.did_user_ftplugin = true
end
