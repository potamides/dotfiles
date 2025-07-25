--[[
  Configure pyright and integrate with debugpy (via nvim-dap).
--]]

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
    local pythonPath = vim.fs.joinpath(client.config.root_dir or ".", ".venv/bin/python")
    if vim.uv.fs_stat(pythonPath) then
      -- if there is a virtualenv in root dir, use it (required for pyright)
      client.settings.python.pythonPath = pythonPath
    end

    -- NOTE: cannot set on_attach directly as it would overwrite lspconfig one
    local orig_on_attach = client.on_attach or function() end
    function client.on_attach(id, bufnr)
      orig_on_attach(id, bufnr)
      vim.keymap.set(
        "n", "<localleader>or", '<cmd>LspPyrightOrganizeImports<cr>', {silent = true, buffer = bufnr}
      )
    end

    -- disable LSP semantic highlighting (only relevant for basedpyright)
    client.server_capabilities.semanticTokensProvider = nil
  end
}
