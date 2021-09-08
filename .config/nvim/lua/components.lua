--[[
  Custom component functions for lightline. Mainly LSP related.
--]]

local comps = {
  spinner = {
    index = 1,
    timer = vim.loop.new_timer(),
    status = ""
  },
  signs = {
    edit     = "+",
    lock     = "-",
    git      = "↨",
    error    = "‼",
    warning  = "!",
    filetype = "≡",
    spinner  = {"-", "\\", "|", "/"}
  },
  string = {}
}

function comps.get_sign(name)
  local sign = comps.signs[name]
  return type(sign) == "function" and sign() or sign
end

function comps.narrow()
  return vim.fn.winwidth(0) < 95
end

-- filename in the same format as lightline-bufferline
function comps.filename()
  local filename = vim.fn.expand("%:t", false, true)[1] or "*"
  local editable = vim.o.modifiable and not vim.o.readonly
  local suffix = editable and (vim.o.modified and " " .. comps.get_sign("edit") or "") or " " .. comps.get_sign("lock")
  return comps.get_sign("filetype") .. " " .. filename .. suffix
end

-- current git branch
function comps.gitbranch()
  if comps.narrow() then
    return ""
  else
    return vim.b.gitsigns_head and comps.get_sign("git") .. " " .. vim.b.gitsigns_head or ""
  end
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

-- lsp errors
function comps.errors()
  local errors = vim.lsp.diagnostic.get_count(0, "Error")
  return errors > 0 and comps.get_sign("error") .. " " .. errors or ""
end

-- lsp warnings
function comps.warnings()
  local warnings = vim.lsp.diagnostic.get_count(0, "Warning")
  return warnings > 0 and comps.get_sign("warning") .. " " .. warnings or ""
end

function comps.setup(signs)
  comps.signs = vim.tbl_extend("force", comps.signs, signs or {})

  -- comps.string.* returns string representations of  comps.* methods in a
  -- format that is callable by viml
  setmetatable(comps.string, {
    __index = function(table, key)
      if comps[key] and type(comps[key]) == "function" then
        vim.g["lightline_" .. key] = comps[key]
        table[key] = "g:lightline_" .. key
        return table[key]
      end
    end
  })

  -- update lsp diagnostics information inside lightline
  vim.cmd([[
    augroup lightline_diagnostics
      autocmd!
      autocmd User LspDiagnosticsChanged,LspProgressUpdate call lightline#update()
    augroup END
  ]])
end

return comps
