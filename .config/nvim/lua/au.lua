--[[
Small wrapper around autocmd functions.
--]]

-- Create an augroup and return a table for defining autocmds in this augroup.
local function au(group)
  local augroup = {_mt = {}}

  -- Define new autocmds with au("<group>").<event> = function() ... end.
  function augroup._mt.__newindex(_, event, handler)
    vim.api.nvim_create_autocmd(event, {
      group = group,
      callback = handler
    })
  end

  -- With multiple events, or specific opts use au("<group>")(<event>, [<opts>])...
  function augroup._mt.__call(_, event, opts)
    opts = opts or {}
    local autocmd = {_mt = {}}

    -- ... and then define a handler in the returned table, the key doesn't matter.
    function autocmd._mt.__newindex(_, _, handler)
      opts.group = group
      opts.callback = handler
      vim.api.nvim_create_autocmd(event, opts)
    end

    return setmetatable(autocmd, autocmd._mt)
  end

  if group then
    vim.api.nvim_create_augroup(group, {clear = true})
  end

  return setmetatable(augroup, augroup._mt)
end

return au
