--[[
  This plugin defines a 'thesaurusfunc' which can read thesauri written in the
  openoffice.org mythes format. When 'thesaurusfunc' is set to this function,
  this allows users to add such thesauri to the 'thesaurus' option.

  See https://wiki.services.openoffice.org/wiki/Dictionaries
--]]

vim.openoffice = {}

-- Emulate lazy evaluation. Could be made better with __pairs, __ipairs and
-- __len metatable events from lua 5.2+ (which we don't have in Neovim).
local function lazy_table(iterator)
  return setmetatable({}, {__index = function(tbl, idx)
    while #tbl < idx do
      table.insert(tbl, iterator())
    end
    return tbl[idx]
  end})
end

local function find_start_byte(iterator, end_line, base)
  local start_line, term, lines = 1, (base .. "|"):lower(), lazy_table(iterator)

  while start_line <= end_line do
    local line = math.floor((start_line + end_line) / 2)
    if vim.startswith(lines[line], term) then
      return tonumber(lines[line]:sub(#term + 1))
    elseif vim.stricmp(base, vim.split(lines[line], "|")[1]) < 0 then
      end_line = line - 1
    else
      start_line = line + 1
    end
  end
  return -1
end

local function parse_entry(iterator, length, base)
  local completions = {}
  for _ = 1, length do
    local synonyms = vim.split(iterator(), "|")
    local pos = table.remove(synonyms, 1)
    for _, synonym in ipairs(synonyms) do
      -- remove additional information for to be inserted word which is often given in parentheses
      local insert = vim.trim(synonym:gsub("%(.-%)", ""):gsub(" +", " "))
      if vim.stricmp(base, insert) ~= 0 then
        table.insert(completions, {
          abbr = synonym,
          word = insert,
          menu = not vim.tbl_contains({"-", ""}, pos) and (pos:match("^%((.+)%)$") or pos) or nil
        })
      end
    end
  end
  return completions
end

function vim.openoffice.thesaurusfunc(findstart, base)
  if findstart == 1 then
    local line, col = vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)[2]
    return vim.fn.match(line:sub(1, col), '\\k*$')
  end

  local completions, term = {}, base:lower() .. "|"
  for _, dat_file in ipairs(vim.opt.thesaurus:get()) do
    -- thesaurus usually comes with an index file which can be used for binary
    -- search (faster)
    local idx_file, start_byte = vim.fn.fnamemodify(dat_file, ":r") .. ".idx"
    if vim.fn.filereadable(idx_file) == 1 then
      local idx_iter = io.lines(idx_file)
      idx_iter() -- skip encoding info in first line
      local length = tonumber(idx_iter())
      start_byte = find_start_byte(idx_iter, length, base)
    end

    local entries = io.open(dat_file)
    if entries and start_byte ~= -1 then
      -- skip to first byte or after encoding info in first line
      entries:seek("set", start_byte or #entries:read() + 1)
      local iterator = entries:lines()
      for line in iterator do
        if vim.startswith(line, term) then
          local length = tonumber(line:sub(#term + 1))
          vim.list_extend(completions, parse_entry(iterator, length, base))
          break
        end
      end
      entries:close()
    end
  end

  return completions
end
