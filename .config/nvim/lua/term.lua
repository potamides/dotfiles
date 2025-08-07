--[[
  Small :term wrapper for opening a terminal at the bottom of the screen with a
  persistent buffer.
--]]
local term = {
  termwin = -1,
  termbuf = -1,
  height = 15,
  opts = {
  }
}

function term:open(args)
  local current = vim.fn.win_getid()
  args = args or {}

  -- if term is not valid open a new one
  if not vim.api.nvim_win_is_valid(self.termwin) then
    vim.cmd.split{range = {self.height}, mods = {split = "botright"}}
    vim.opt_local.winfixheight = true
    self.termwin = vim.api.nvim_get_current_win()
  else
    -- if someone stole our window but there is only one window in total create
    -- a new split before taking our old window back
    if #vim.api.nvim_tabpage_list_wins(0) == 1 and vim.api.nvim_win_get_buf(self.termwin) ~= self.termbuf then
      vim.cmd.split()
    end
    -- take our window back, just in case
    vim.api.nvim_set_current_win(self.termwin)
    -- only resize if there are more then one windows
    if #vim.api.nvim_list_wins() > 1 then
      vim.cmd.wincmd("J")
      vim.cmd.resize(self.height)
    end
  end

  if not vim.api.nvim_buf_is_valid(self.termbuf) then
    self.termbuf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(self.termbuf)
    if args.cmd ~= false then -- false means jobstart is handled externally
      vim.fn.jobstart(args.cmd or vim.o.shell, {term = true, unpack(args.opts or {})})
    end
    for opt, val in pairs(self.opts) do
      vim.opt_local[opt] = val
    end
  else
    vim.api.nvim_set_current_buf(self.termbuf)
  end

  if args.nofocus then
    vim.api.nvim_set_current_win(current)
  elseif not args.noinsert then
    vim.cmd.startinsert()
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
