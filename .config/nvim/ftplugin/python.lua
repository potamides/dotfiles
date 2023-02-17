--[[
  Setup pyright language server and debugpy debug adapter. Also set some
  filetype-specific options.
--]]

if not vim.b.did_user_ftplugin then
  local dap = require('dap')
  local pyright = require("lsputils").pyright

  dap.adapters.debugpy = dap.adapters.debugpy or {
    type = 'executable',
    command = vim.g.python3_host_prog,
    args = {'-m', 'debugpy.adapter'}
  }

  dap.configurations.python = dap.configurations.python or {
    {
      type = 'debugpy',
      request = 'launch',
      name = "Launch file",

      console = "integratedTerminal",
      program = "${file}", -- launch the current file...
      cwd = "${fileDirname}", -- ...in its directory
      --justMyCode = false
    }
  }

  pyright.setup{
    settings = {
      python = {
        analysis = {
          autoImportCompletions  = false, -- doesn't work with omnifunc
          useLibraryCodeForTypes = true,
          diagnosticMode = "openFilesOnly" -- "workspace" is too slow for big projects
        }
      }
    },
    on_new_config = function(config, root_dir)
      -- If we have a folder in the root directory whose name contains the
      -- string "venv" treat it as a virtual env folder and activate it.
      local venv = vim.fn.globpath(root_dir, ".*venv*\\|*venv*", nil, true)[1]
      if venv then
        config.cmd_env = {
          PATH = ("%s/bin:%s"):format(venv, vim.env.PATH),
          VIRTUAL_ENV = venv,
        }
        -- we also use the virtual env for debugpy
        for _, dapconf in ipairs(dap.configurations.python) do
          dapconf.python = ("%s/bin/python"):format(venv)
        end
      end
    end
  }

  vim.keymap.set("n", "<localleader>or", '<cmd>PyrightOrganizeImports<cr>', {silent = true, buffer = true})

  -- when black is installed use it for formatting with 'gq' operator
  if vim.fn.executable("black") == 1 then
    vim.opt_local.formatprg = "black --fast --quiet -"
  end

  -- /usr/share/nvim/runtime/ftplugin/python.vim unconditionally overwrites
  -- omnifunc, so we have to reset it >:(
  vim.opt_local.omnifunc = vim.opt_global.omnifunc:get()

  vim.opt_local.formatoptions:append{
    t = false, -- auto-wrap text using textwidth
    r = true,  -- auto insert comment leader after hitting <Enter>
    l = true   -- when a line was longer than 'textwidth' when insert started, do not auto-format it
  }

  vim.b.did_user_ftplugin = true
end
