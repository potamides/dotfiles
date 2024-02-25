--[[
  Add missing imports on complete using the built-in omnifunc. Based on:
  https://www.reddit.com/r/neovim/comments/mn8ipa/lsp_add_missing_imports_on_complete_using_the
--]]

local au = require("au")
local group = au("omnifunc_import_complete")

function group.CompleteDone()
  local item = vim.tbl_get(vim.v.completed_item, "user_data", "nvim", "lsp", "completion_item")
  local bufnr, fileencoding = vim.api.nvim_get_current_buf(), vim.bo.fileencoding
  if item then
    vim.lsp.buf_request(bufnr, "completionItem/resolve", item, function(_, _, result)
      local edits = vim.tbl_get(result, "params", "additionalTextEdits")
      if edits then
        vim.lsp.util.apply_text_edits(edits, bufnr, fileencoding)
      end
    end)
  end
end
