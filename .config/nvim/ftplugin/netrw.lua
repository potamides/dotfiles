--[[
  Map bookmark handler to 'b and `b and change vertical bar in netrw windows.
--]]

if not vim.b.did_user_ftplugin then

  -- change vertical bar from | to │ by (ab)using concealing
  vim.fn.matchadd("Conceal", [[\(^\([-+|] \)*\)\@<=| \@=]], nil, -1, {conceal="│"})
  vim.wo.winhighlight = "Conceal:netrwTreeBar"
  vim.wo.conceallevel = 2
  vim.wo.concealcursor = "nvic"
  vim.wo.list = false -- in empty directories there is trailing whitespace

  vim.b.did_user_ftplugin = true
end
