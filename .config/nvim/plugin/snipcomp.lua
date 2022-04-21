--[[
  Companion plugin for the LuaSnip snippet engine. Defines a completion
  function which can be used for built-in insert mode completion (e.g. omni
  completion). See 'ins-completion' for details. After completion the snippet
  is expanded.
--]]

-- lazy load LuaSnip, only useful when LuaSnip wasn't already loaded elsewhere
local luasnip = setmetatable({}, {__index = function(_, key) return require("luasnip")[key] end})
local au = require("au")
vim.luasnip = {}

local function snippet2completion(snippet)
  return {
    word      = snippet.trigger,
    menu      = snippet.name,
    info      = vim.trim(table.concat(vim.tbl_flatten({snippet.dscr or "", "", snippet:get_docstring()}), "\n")),
    dup       = true,
    user_data = "luasnip"
  }
end

local function snippetfilter(line_to_cursor, base)
  return function(s)
    return not s.hidden and vim.startswith(s.trigger, base) and s.show_condition(line_to_cursor)
  end
end

-- Set 'completefunc' or 'omnifunc' to 'v:lua.vim.luasnip.completefunc' to get
-- completion.
function vim.luasnip.completefunc(findstart, base)
  local line, col = vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)[2]
  local line_to_cursor = line:sub(1, col)

  if findstart == 1 then
    return vim.fn.match(line_to_cursor, '\\k*$')
  end

  local snippets = vim.list_extend(vim.list_slice(luasnip.get_snippets("all")), luasnip.get_snippets(vim.bo.filetype))
  snippets = vim.tbl_filter(snippetfilter(line_to_cursor, base), snippets)
  snippets = vim.tbl_map(snippet2completion, snippets)
  table.sort(snippets, function(s1, s2) return s1.word < s2.word end)
  return snippets
end

local luasnip_completion_expand = au("luasnip_completion_expand")
function luasnip_completion_expand.CompleteDone()
  if vim.v.completed_item.user_data == "luasnip" and luasnip.expandable() then
    luasnip.expand()
  end
end
