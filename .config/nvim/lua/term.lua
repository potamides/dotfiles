--[[
  Small :term wrapper for opening a terminal at the bottom of the screen with a
  persistent buffer.
--]]
local term = {
  termwin = -1,
  termbuf = -1,
  height = 15,
  augroup = vim.api.nvim_create_augroup("toggleterm", {}),
}

function term:open(args)
  args = args or {}
  if not vim.api.nvim_win_is_valid(self.termwin) then
    vim.cmd(('botright %dsplit'):format(self.height))
    vim.opt_local.winfixheight = true
    self.termwin = vim.api.nvim_get_current_win()
  else
    vim.api.nvim_set_current_win(self.termwin)
    vim.cmd(("wincmd J | resize %d"):format(self.height))
  end

  if not vim.api.nvim_buf_is_valid(self.termbuf) then
    self.termbuf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(self.termbuf)

    if args.cmd ~= false then -- false means termopen is handled externally
      vim.fn.termopen(args.cmd or vim.o.shell)
    end

    vim.api.nvim_create_autocmd("BufEnter", {
      group = self.augroup,
      buffer = self.termbuf,
      callback = function()
        if #vim.api.nvim_list_wins() == 1 then
          vim.cmd[[quit]]
        end
      end
    })
  else
    vim.api.nvim_set_current_buf(self.termbuf)
  end

  if args.nofocus then
    vim.api.nvim_set_current_win(vim.fn.win_getid(vim.fn.winnr("#")))
  elseif not args.noinsert then
    vim.cmd[[startinsert]]
  end

  return self.termbuf, self.termwin
end

function term:close()
  if vim.api.nvim_win_is_valid(self.termwin) then
    vim.api.nvim_win_hide(self.termwin)
  end
end

function term:destroy()
  if vim.api.nvim_buf_is_valid(self.termbuf) then
    vim.api.nvim_buf_delete(self.termbuf, {force = true})
  end
end

-- create a terminal instance with its own buffer but same window
function term.instance()
  return setmetatable({termbuf = -1}, {
    __index = term,
    __newindex = function(_, k, v) term[k] = v end
  })
end

return setmetatable(term, {__call = term.instance})
