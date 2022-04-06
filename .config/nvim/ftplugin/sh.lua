--[[
  Setup bash language server.
--]]

if not vim.b.did_user_ftplugin then
  require("lsputils").bashls.setup{
    handlers = {
      -- Bashls sends hover info for commands using man-page syntax, but the default
      -- hover handler displays it as markdown code blocks which doesn't have
      -- nice syntax highlighting. This implementation trims code blocks and
      -- displays them using their corresponding syntax highlighting.
      ["textDocument/hover"] = function(_, result, ctx, config)
        config = config or {}
        config.focus_id = ctx.method
        if not (result and result.contents) then
          -- return { 'No information available' }
          return
        end
        local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
        local language_id = vim.trim(vim.lsp.util.try_trim_markdown_code_blocks(markdown_lines))
        markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
        if vim.tbl_isempty(markdown_lines) then
          -- return { 'No information available' }
          return
        end
        return vim.lsp.util.open_floating_preview(markdown_lines, language_id, config)
    end
  }

  }
end
