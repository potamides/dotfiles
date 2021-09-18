--[[
  Companion plugin for the LuaSnip snippet engine. Defines a completion
  function which can be used for insert mode completion or omni completion. See
  'ins-completion' for details. After completion the snippet is expanded.
--]]

-- lazy load LuaSnip, only useful when LuaSnip wasn't already loaded elsewhere
local luasnip = setmetatable({}, {__index = function(_, key) return require("luasnip")[key] end})
vim.luasnip = {}

local function snippet2completion(snippet)
  local docstring = snippet:get_docstring()
  return {
    word      = snippet.trigger,
    menu      = snippet.name,
    info      = type(docstring) == "table" and table.concat(docstring, "\n") or docstring,
    dup       = true,
    user_data = "luasnip"
  }
end

-- Set 'completefunc' or 'omnifunc' to 'v:lua.vim.luasnip.completefunc' to get
-- completion.
function vim.luasnip.completefunc(findstart, base)
  if findstart == 1 then
    return vim.fn.match(vim.fn.getline("."):sub(1, vim.fn.col(".")), '\\k*$')
  end

  local snippets = vim.list_extend(vim.list_slice(luasnip.snippets.all), luasnip.snippets[vim.bo.filetype] or {})
  snippets = vim.tbl_filter(function(snippet) return vim.startswith(snippet.trigger, base) end, snippets)
  snippets = vim.tbl_map(snippet2completion, snippets)
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
