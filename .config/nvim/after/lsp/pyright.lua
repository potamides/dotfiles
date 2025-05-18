--[[
  Configure pyright and integrate with debugpy (via nvim-dap).
--]]

local dap = require('dap')

return {
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        autoImportCompletions  = true,
        useLibraryCodeForTypes = true, -- can get slow for big projects
        diagnosticMode = "workspace",
        typeCheckingMode = "standard"
      }
    }
  },
  commands = {
    ['pyright.organizeimports'] = function(params, args)
      local client = vim.lsp.get_client_by_id(args.client_id)
      client.request('workspace/executeCommand', params, nil, args.bufnr)
    end
  },
  on_init = function(client)
    -- if there is a virtualenv in root dir, use it (only for pyright)
    local pythonPath = vim.fs.joinpath(client.config.root_dir, ".venv/bin/python")
    if vim.uv.fs_stat(pythonPath) and client.settings.python then
      client.settings.python.pythonPath = pythonPath
      -- we also use the virtual env for debugpy
      for _, dapconf in ipairs(dap.configurations.python or {}) do
        dapconf.python = pythonPath
      end
    end

    vim.keymap.set(
      "n", "<localleader>or", '<cmd>LspPyrightOrganizeImports<cr>', {silent = true, buffer = true}
    )

    -- disable LSP semantic highlighting (only relevant for basedpyright)
    client.server_capabilities.semanticTokensProvider = nil
  end,
  on_exit = function()
    for _, dapconf in ipairs(dap.configurations.python or {}) do
      dapconf.python = nil
    end
  end
}
