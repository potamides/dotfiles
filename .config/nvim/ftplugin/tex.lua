--[[
  Setup texlab language server.
--]]

if not vim.b.loaded_tex_lsp then
  local texlab = require("lspconfig").texlab

  if not texlab.manager then
    texlab.setup{
      settings = {
        texlab = {
          build = {
            args = {"-interaction=nonstopmode", "-synctex=1", "-pv", "%f"},
            forwardSearchAfter = true
          },
          forwardSearch = {
            executable = "qpdfview",
            args = {"--unique", "%p#src:%f:%l:1"}
          },
          chktex = {
            onEdit = true,
            onOpenAndSave = true
          }
        }
      }
    }

    if not (texlab.autostart == false) then
      texlab.manager.try_add()
    end
  end

  local function set_keymap(lhs, rhs)
    local template = '<cmd>lua require("lspconfig").texlab.commands.%s[1]()<CR>'
    vim.api.nvim_buf_set_keymap(0, "n", lhs, string.format(template, rhs), {noremap=true, silent=true})
  end

  set_keymap("<localleader>bn", "TexlabBuild")
  set_keymap("<localleader>fs", "TexlabForward")

  vim.b.loaded_tex_lsp = true
end
