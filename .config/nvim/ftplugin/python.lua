--[[
  Setup pyright language server. Also set some filetype-specific options.
--]]

if not vim.b.did_user_ftplugin then
  local pyright = require("lsputils").pyright

  pyright.setup{
    settings = {
      python = {
        analysis = {
          autoImportCompletions  = false, -- does't work with omnifunc
          useLibraryCodeForTypes = true,
          diagnosticMode = "openFilesOnly" -- "workspace" is too slow for big projects
        }
      }
    }
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
