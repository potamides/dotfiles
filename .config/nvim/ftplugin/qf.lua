--[[
  Remove the quickfix window from the buffer list and close nvim when qf is
  last window.
]]
if not vim.b.did_user_ftplugin then
  vim.opt_local.buflisted = false
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup(vim.bo.filetype, {}),
    buffer = 0,
    callback = function()
      if #vim.api.nvim_list_wins() == 1 then
        vim.cmd[[quit]]
      end
    end}
  )
  vim.b.did_user_ftplugin = true
end
