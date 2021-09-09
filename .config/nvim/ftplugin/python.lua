--[[
  Setup pyright language server.
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

  -- no lsp-based folding yet, unfortunately
  -- (see https://github.com/neovim/neovim/pull/14306)
  vim.bo.textwidth = 120

  vim.b.loaded_python_lsp = true
end
