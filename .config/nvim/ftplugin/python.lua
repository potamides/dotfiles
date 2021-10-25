--[[
  Setup pyright language server. Also set some filetype-specific options.
--]]

if not vim.b.did_user_ftplugin then
  local pyright = require("lspconfig").pyright

  if not pyright.manager then
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

    if not (pyright.autostart == false) then
      pyright.manager.try_add_wrapper()
    end
  end

  vim.api.nvim_buf_set_keymap(0, "n", "<localleader>or", '<cmd>PyrightOrganizeImports<cr>', {silent=true})

  -- customize how automatic formatting is done
  vim.opt_local.formatoptions:append{
    t = false,
    r = true,
    l = true
  }

  vim.b.did_user_ftplugin = true
end
