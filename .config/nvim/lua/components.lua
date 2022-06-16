--[[
  Custom component functions for lightline. Mainly LSP/diagnostics related.
--]]

local au = require("au")

local comps = {
  opts = {
    signs = {
      edit     = "+",
      lock     = "-",
      git      = "↨",
      error    = "‼",
      warning  = "!",
      filetype = "≡",
      spinner  = {"-", "\\", "|", "/"}
    },
    narrow_width = 95,
  },
  spinner = {
    index = 1,
    timer = vim.loop.new_timer(),
    status = ""
  },
  string = {},
  narrow = {
    string = {}
  }
}

function comps.get_sign(name)
  local sign = comps.opts.signs[name]
  return type(sign) == "function" and sign() or sign
end

-- check if the terminal is narrow, can be used to hide components based on
-- window width through components.narrow.* methods
function comps.is_narrow()
  return vim.fn.winwidth(0) < comps.opts.narrow_width
end

-- filename in the same format as lightline-bufferline
function comps.filename()
  local filename = vim.fn.expand("%:t", false, true)[1] or "[No Name]"
  local editable = vim.o.modifiable and not vim.o.readonly
  local suffix = editable and (vim.o.modified and " " .. comps.get_sign("edit") or "") or " " .. comps.get_sign("lock")
  return comps.get_sign("filetype") .. " " .. filename .. suffix
end

-- current git branch
function comps.gitbranch()
  return vim.b.gitsigns_head and comps.get_sign("git") .. " " .. vim.b.gitsigns_head or ""
end

-- lsp progress indicator
function comps.progress()
  if comps.spinner.timer:get_due_in() == 0 then
    local message = vim.lsp.util.get_progress_messages()[1]
    if message then
      comps.spinner.timer:start(75, 0, vim.schedule_wrap(function()
        comps.spinner.index = comps.spinner.index % #comps.get_sign("spinner") + 1
        vim.fn['lightline#update']()
      end))
      local title = vim.tbl_contains({"", "empty title"}, message.title) and "Loading" or message.title
      comps.spinner.status = comps.get_sign("spinner")[comps.spinner.index] .. " " .. title
    else
      comps.spinner.status = ""
    end
  end
  return comps.spinner.status
end

-- error diagnostics
function comps.errors()
  local errors = #vim.diagnostic.get(0, {severity=vim.diagnostic.severity.ERROR})
  return errors > 0 and comps.get_sign("error") .. " " .. errors or ""
end

-- warning diagnostics
function comps.warnings()
  local warnings = #vim.diagnostic.get(0, {severity=vim.diagnostic.severity.WARN})
  return warnings > 0 and comps.get_sign("warning") .. " " .. warnings or ""
end

function comps.setup(opts)
  comps.opts = vim.tbl_extend("force", comps.opts, opts or {})

  -- components.string.* and components.narrow.string.* returns string
  -- representations of components.* and components.narrow.* methods in a
  -- format that is callable by viml
  for _, components in ipairs{comps, comps.narrow} do
    setmetatable(components.string, {
      __index = function(table, key)
        if components[key] and type(components[key]) == "function" then
          vim.g["_lightline_" .. key] = components[key]
          table[key] = "g:_lightline_" .. key
          return table[key]
        end
      end
    })
  end

  -- components.narrow.* returns wrappers around components.* methods which
  -- auto hide components in narrow terminal windows
  setmetatable(comps.narrow, {
    __index = function(table, key)
      if comps[key] then
        table[key] = function() return comps.is_narrow() and "" or comps[key]() end
        return table[key]
      end
    end
  })

  -- update lsp diagnostics information inside lightline
  local lightline_diagnostics = au("lightline_diagnostics")
  function lightline_diagnostics.DiagnosticChanged()
    vim.fn["lightline#update"]()
  end

  function lightline_diagnostics.User(args)
    if args.match == "LspProgressUpdate" then
      vim.fn["lightline#update"]()
    end
  end
end

return comps
