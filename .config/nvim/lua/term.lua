--[[
Small :term wrapper for opening a terminal at the bottom of the screen with a persistent buffer.
--]]
local term = {
  termwin = -1,
  termbuf = -1,
  height = 12,
  augroup = vim.api.nvim_create_augroup("toggleterm", {})
}

function term.open(cmd)
  if not vim.api.nvim_win_is_valid(term.termwin) then
    vim.cmd(('botright %dsplit'):format(term.height))
    vim.opt_local.winfixheight = true
    term.termwin = vim.api.nvim_get_current_win()
  else
    vim.api.nvim_set_current_win(term.termwin)
    vim.cmd(("wincmd J | resize %d"):format(term.height))
  end

  if not vim.api.nvim_buf_is_valid(term.termbuf) then
    term.termbuf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(term.termbuf)
    vim.fn.termopen(cmd or vim.o.shell)

    vim.api.nvim_create_autocmd("BufEnter", {
      group = term.augroup,
      buffer = term.termbuf,
      callback = function()
        if #vim.api.nvim_list_wins() == 1 then
          vim.cmd[[quit]]
        end
      end}
    )
  else
    vim.api.nvim_set_current_buf(term.termbuf)
  end
  vim.cmd[[startinsert]]
end

return term
