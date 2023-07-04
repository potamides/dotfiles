--[[
  By default, Neovims LSP omnifunc uses an empty space as a fallback for
  missing completion information. Should 'completeopt' contain preview, this
  has the effect that for each item without completion information, the preview
  window opens and shows nothing. This companion plugin changes this behavior
  by trimming excess whitespace so that for empty infos no preview window
  opens.
--]]

local complete_items = vim.lsp.util.text_document_completion_list_to_complete_items

function vim.lsp.util.text_document_completion_list_to_complete_items(...)
  local matches = complete_items(...)
  for _, match in ipairs(matches) do
    match.info = vim.trim(match.info)
  end

  return matches
end
