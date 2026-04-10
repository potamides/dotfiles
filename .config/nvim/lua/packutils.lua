--[[
  Utility functions for use with vim.pack. Also adds support for a custom
  'build' key in plugin specs to run build scripts and a 'patch' key to apply
  patches to installed plugins.
--]]

local packutils = {}

function packutils.totable(obj)
  return type(obj) == "table" and obj or {obj}
end

function packutils.request_sync(url, opts)
  local done, body, err_msg = false

  vim.net.request(url, opts or {}, function(err, res)
    done, body, err_msg = true, (res or {}).body, err
  end)
  vim.wait(math.huge, function() return done end)

  if err_msg then
    error(err_msg)
  end
  return body
end

function packutils.gh(proj)
  return 'https://github.com/' .. proj
end

function packutils.npm(proj)
  return function() vim.system(
    {"npm", "update", "-g", unpack(packutils.totable(proj))},
    {NPM_CONFIG_PREFIX=vim.fn.expand("~/.local")}):wait()
  end
end

function packutils.parse_extended_spec(ev)
  local data, kind, path = ev.data.spec.data or {}, ev.data.kind, ev.data.path

  if kind == 'install' or kind == 'update' then
    -- apply patches
    if data.patch then
      for _, uri in ipairs(packutils.totable(data.patch)) do
        local patch = packutils.request_sync(uri)
        vim.system({"git", "apply"}, {cwd = path, stdin = patch}):wait()
      end
    end

    -- run build script
    if data.build then
      for _, build in ipairs(packutils.totable(data.build)) do
        if vim.is_callable(build) then
          data.build()
        else
          vim.system(vim.split(build, "%s", {trimempty=true}), { cwd = path }):wait()
        end
      end
    end
  end
end

function packutils.safe_parse_extended_spec(ev)
  xpcall(
    function() return packutils.parse_extended_spec(ev) end,
    function(msg) vim.notify(msg, vim.log.levels.ERROR) end
  )
end

-- install hook to enable support for extended plugin spec
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("user_packutils", {clear = true}),
  callback = packutils.safe_parse_extended_spec
})

return packutils
