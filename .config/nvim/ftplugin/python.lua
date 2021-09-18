--[[
  Setup pyright language server. Also set some filetype-specific options.
--]]

if not vim.b.loaded_python_lsp then
  local pyright = require("lspconfig").pyright

  if not pyright.manager then
    pyright.setup{
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "off"
          }
        }
      }
    }

    if not (pyright.autostart == false) then
      pyright.manager.try_add()
    end
  end

  -- customize how automatic formatting is done
  vim.opt_local.formatoptions:append{
    t = false,
    r = true,
    l = true
  }

  vim.b.loaded_python_lsp = true
end
