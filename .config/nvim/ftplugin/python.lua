--[[
  Setup pyright language server. Also set some filetype-specific options.
--]]

if not vim.b.did_user_ftplugin then
  local pyright = require("lsputils").pyright

  pyright.setup{
    settings = {
      python = {
        analysis = {
          autoImportCompletions  = true,
          useLibraryCodeForTypes = false
        }
      }
    }
  }

  vim.api.nvim_buf_set_keymap(0, "n", "<localleader>or", '<cmd>PyrightOrganizeImports<cr>', {silent=true})

  -- when black is installed use it for formatting with 'gq' operator
  if vim.fn.executable("black") == 1 then
    vim.opt_local.formatprg = "black --fast --quiet -"
  end

  -- customize how internal formatting is done
  vim.opt_local.formatoptions:append{
    t = false,
    r = true,
    l = true
  }

  vim.b.did_user_ftplugin = true
end
