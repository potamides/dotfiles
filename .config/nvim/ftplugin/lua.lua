--[[
  Setup sumneko language server. It is configured for both use with neovim and
  awesome wm. Also set some filetype-specific options.
--]]

if not vim.b.did_user_ftplugin then
  local sumneko = require("lspconfig").sumneko_lua

  if not sumneko.manager then
    sumneko.setup {
      cmd = {"lua-language-server", "-E", "/usr/share/lua-language-server/main.lua"};
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
              "client"
            },
          },
          workspace = {
            --preload global variables and classes
            library = vim.list_extend(
              -- awesome wm library
              {"/usr/share/awesome/lib"},
              -- neovim stuff
              vim.api.nvim_get_runtime_file("", true)),
          }
        }
      }
    }

    if not (sumneko.autostart == false) then
      sumneko.manager.try_add_wrapper()
    end
  end

  -- customize how automatic formatting is done
  vim.opt_local.formatoptions:append{
    o = false,
  }

  vim.b.did_user_ftplugin = true
end
