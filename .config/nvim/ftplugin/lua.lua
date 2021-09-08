--[[
  Setup sumneko language server. It is configured for both use with neovim and
  awesome wm.
--]]

if not vim.b.loaded_python_lsp then
  local sumneko = require("lspconfig").sumneko_lua

  if not sumneko.manager then
    local runtime_path = vim.split(package.path, ';')
    -- neovim lua modules
    vim.list_extend(runtime_path, {"lua/?.lua", "lua/?/init.lua"})

    sumneko.setup {
      cmd = {"lua-language-server", "-E", "/usr/share/lua-language-server/main.lua"};
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
            -- match the file name when entering require('XYZ')
            path = runtime_path
          },
          diagnostics = {
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
      sumneko.manager.try_add()
    end
  end

  vim.b.loaded_python_lsp = true
end