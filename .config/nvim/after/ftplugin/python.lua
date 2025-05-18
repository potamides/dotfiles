--[[
  Setup debugpy debug adapter. Also set some filetype-specific options.
--]]

if not vim.b.did_user_ftplugin then
  local dap = require('dap')

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
      justMyCode = false,

      args = function()
        local args = vim.fn.input("Arguments: ")
        if #args > 0 then
          return vim.split(vim.fn.expandcmd(args), " +")
        end
      end
    }
  }

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
