--[[
  Small :term wrapper for opening a terminal at the bottom or as a sidebar of
  the screen with a persistent buffer.
--]]
local term = {
  sidebar = false,
  termbuf = -1,
  horizontal = {
    termwin = -1,
    size = 15,
    split = "split",
    wincmd = "J"
  },
  vertical = {
    termwin = -1,
    size = 80,
    split = "vsplit",
    wincmd = "L"
  },
  opts = {
    winfixheight = true,
    winfixwidth = true
  },
  _M = {}
}

function term:open(args)
  local current = vim.fn.win_getid()
  args = args or {}

  -- if term is not valid open a new one
  if not vim.api.nvim_win_is_valid(self.termwin) then
    vim.cmd[self.split]{range = {self.size}, mods = {split = "botright"}}
    for opt, val in pairs(self.opts) do
      vim.opt_local[opt] = val
    end
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
      vim.cmd.wincmd(self.wincmd)
      vim.cmd.resize{self.size, mods = {vertical = self.sidebar}}
    end
  end

  if not vim.api.nvim_buf_is_valid(self.termbuf) then
    self.termbuf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(self.termbuf)
    if args.cmd ~= false then -- false means jobstart is handled externally
      vim.fn.jobstart(args.cmd or vim.o.shell, vim.tbl_extend("error", {term = true}, args.opts or {}))
    end
  else
    vim.api.nvim_set_current_buf(self.termbuf)
  end

  -- make term window mutually exclusive with quickfix windows (also see
  -- after/ftplugin/qf.lua)
  if not self.sidebar then
    vim.cmd.cclose()
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

function term:send(arg)
  if not arg then -- see :h :map-operator
    vim.opt.operatorfunc = ([[{arg -> v:lua.require'term'.send({'termwin': %d}, arg)}]]):format(self.termwin)
    return vim.api.nvim_win_is_valid(self.termwin) and 'g@' or ''
  end

  local start, finish, text = vim.api.nvim_buf_get_mark(0, "["), vim.api.nvim_buf_get_mark(0, "]")
  if arg == "char" then
    text = vim.api.nvim_buf_get_text(0, start[1] - 1, start[2], finish[1], finish[2])
  else -- linewise
    text = vim.api.nvim_buf_get_lines(0, start[1] - 1, finish[1], true)
  end

  vim.api.nvim_win_call(self.termwin, function()
    vim.api.nvim_paste(table.concat(text, "\n"), true, -1)
  end)
end

-- create a terminal instance with its own buffer but same window
function term.instance(sidebar)
  return setmetatable({termbuf = -1, sidebar = sidebar or false}, term._M)
end

function term._M.__index(tbl, key)
  if not rawget(term, key) then
    if tbl.sidebar then
      return term.vertical[key]
    end
    return term.horizontal[key]
  end
  return term[key]
end

function term._M.__newindex(tbl, key, value)
  if not rawget(term, key) then
    if tbl.sidebar then
      term.vertical[key] = value
    else
      term.horizontal[key] = value
    end
  else
    term[key] = value
  end
end

function term._M.__call(tbl, ...)
  return tbl.instance(...)
end

return setmetatable(term, term._M)
