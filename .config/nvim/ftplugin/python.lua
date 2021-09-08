--[[
  Setup pyright language server.
--]]

if not vim.b.loaded_python_lsp then
  local pyright = require("lspconfig").pyright

  if not pyright.manager then
    pyright.setup{}

    if not (pyright.autostart == false) then
      pyright.manager.try_add()
    end
  end

  vim.b.loaded_python_lsp = true
end
