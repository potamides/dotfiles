--[[
  Setup sumneko language server. It is primarily configured for use with neovim
  and awesome wm. Also set some filetype-specific options.
--]]

if not vim.b.did_user_ftplugin then
  local sumneko = require("lsputils").sumneko_lua

  sumneko.setup{
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
          -- match the file name when entering require('XYZ')
          path = vim.list_extend(
            vim.split(package.path, ';'),
            -- neovim lua modules
            {"lua/?.lua", "lua/?/init.lua"})
        },
        diagnostics = {
          disable = {
            "unbalanced-assignments"
          },
          --neededFileStatus = {
          --  ["codestyle-check"] = "Any",
          --},
          globals = {
            -- neovim globals
            "vim",
            -- awesomewm globals (taken from https://github.com/awesomeWM/awesome/blob/master/.luacheckrc)
            "awesome",
            "button",
            "dbus",
            "drawable",
            "drawin",
            "key",
            "keygrabber",
            "mousegrabber",
            "selection",
            "tag",
            "window",
            "screen",
            "mouse",
            "root",
            "client",
            -- conky
            "conky"
          },
        },
        format = {
          enable = true,
          defaultConfig = {
            -- default format options (i.e. without .editorconfig)
            indent_style = vim.bo.expandtab and "space" or "tab",
            indent_size = tostring(vim.bo.shiftwidth),
            keep_one_space_between_table_and_bracket = "false",
            quote_style = "double",
          }
        },
        workspace = {
          --preload global variables and classes
          library = {
            -- awesome wm library
            "/usr/share/awesome/lib",
            -- neovim stuff
            unpack(vim.api.nvim_get_runtime_file("", true))
          }
        }
      }
    }
  }

  -- auto insert current comment with 'o' or 'O'
  vim.opt_local.formatoptions:append{
    o = false,
  }

  vim.b.did_user_ftplugin = true
end
