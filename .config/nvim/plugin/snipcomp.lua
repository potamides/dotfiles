--[[
  Companion plugin for the LuaSnip snippet engine. Defines a completion
  function which can be used for built-in insert mode completion (e.g. omni
  completion). See 'ins-completion' for details. After completion the snippet
  is expanded.
--]]

-- lazy load LuaSnip, only useful when LuaSnip wasn't already loaded elsewhere
local luasnip = setmetatable({}, {__index = function(_, key) return require("luasnip")[key] end})
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
  local line_to_cursor = vim.fn.getline("."):sub(1, vim.fn.col("."))
  if findstart == 1 then
    return vim.fn.match(line_to_cursor, '\\k*$')
  end

  local snippets = vim.list_extend(vim.list_slice(luasnip.snippets.all), luasnip.snippets[vim.bo.filetype] or {})
  snippets = vim.tbl_filter(snippetfilter(line_to_cursor, base), snippets)
  snippets = vim.tbl_map(snippet2completion, snippets)
  table.sort(snippets, function(s1, s2) return s1.word < s2.word end)
  return snippets
end

function vim.luasnip.completion_expand(item)
  if item.user_data == "luasnip" and luasnip.expandable() then
    luasnip.expand()
  end
end

vim.cmd([[
  augroup luasnip_completion_expand
    autocmd!
    autocmd CompleteDone * call v:lua.vim.luasnip.completion_expand(v:completed_item)
  augroup END
]])
