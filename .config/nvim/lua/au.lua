--[[
Small wrapper around autocmd functions.
--]]

local autocmd_opts = {"group", "pattern", "buffer", "desc", "callback", "command", "once", "nested"}

-- Create an augroup and return a table for defining autocmds in this augroup.
local function au(args)
  local augroup, shorthands, group, opts = {_mt = {}}, {}

  if type(args) == "table" then
    group, opts = table.remove(args, 1), args
  else
    group, opts = args, {}
  end

  for key, value in pairs(opts) do
    if not vim.tbl_contains(autocmd_opts, key) then
      shorthands[key] = value
      opts[key] = nil
    end
  end

  -- Define new autocmds with au("<group>").<event> = function() ... end.
  function augroup._mt.__newindex(_, event, handler)
    event = shorthands[event] and shorthands[event] or event
    vim.api.nvim_create_autocmd(event, vim.tbl_extend("error", opts, {
      group = group,
      callback = handler
    }))
  end

  if group then
    vim.api.nvim_create_augroup(group, {clear = true})
  end

  return setmetatable(augroup, augroup._mt)
end

return au
