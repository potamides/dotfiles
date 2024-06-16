--[[
  Add snippet expansion support for builtin lsp omnifunc through LuaSnip.
--]]

local lsputil = require('lspconfig.util')
local luasnip = setmetatable({}, {__index = function(_, key) return require("luasnip")[key] end})
local au = require("au")

-- enable snippets for all language servers by default
lsputil.default_config.capabilities.textDocument.completion.completionItem.snippetSupport = true

local luasnip_completion_expand = au("luasnip_lsp_completion_expand")
function luasnip_completion_expand.CompleteDonePre()
  local lsp_info = vim.tbl_get(vim.v.completed_item, 'user_data', 'nvim', 'lsp', 'completion_item')
  if lsp_info and lsp_info.insertTextFormat == 2 then
    -- remove the inserted text
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_buf_set_text(0, row - 1, col - #vim.v.completed_item.word, row - 1, col, {""})
    vim.api.nvim_win_set_cursor(0, {row, col - vim.fn.strwidth(vim.v.completed_item.word)})
    -- expand snippet
    luasnip.lsp_expand(vim.tbl_get(lsp_info, "textEdit", "newText") or lsp_info.insertText or lsp_info.label)
  end
end
