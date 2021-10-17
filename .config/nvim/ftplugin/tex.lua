--[[
  Setup texlab language server.
--]]

if not vim.b.did_user_ftplugin then
  local texlab = require("lspconfig").texlab
  local windows = require("lspconfig/ui/windows")

  if not texlab.manager then
    texlab.setup{
      settings = {
        texlab = {
          auxDirectory = vim.fn.isdirectory("build") and "build" or ".",
          build = {
            args = {"-interaction=nonstopmode", "-synctex=1", "%f"},
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
      },
      commands = {
        TexlabLog = {
          function()
            local auxdir, lines = vim.fn.isdirectory("build") and "build" or ".", {}

            for _, file in ipairs(vim.fn.globpath(auxdir, "*.log\\|blg", false, true)) do
              vim.list_extend(lines, vim.fn.readfile(file))
            end

            if not vim.tbl_isempty(lines) then
              local info = windows.percentage_range_window(0.8, 0.7)
              vim.api.nvim_buf_set_lines(info.bufnr, 0, -1, true, lines)
              vim.api.nvim_buf_set_option(info.bufnr, "modifiable", false)
              vim.api.nvim_buf_set_keymap(info.bufnr, "n", "<esc>", "<cmd>bd<CR>", {noremap = true})
              vim.lsp.util.close_preview_autocmd({"BufHidden", "BufLeave"}, info.win_id)
            end
          end,
          description = "Show content of log files in a floating window."
        }
      }
    }

    if not (texlab.autostart == false) then
      texlab.manager.try_add_wrapper()
    end
  end

  local function set_keymap(lhs, rhs)
    local template = '<cmd>lua require("lspconfig").texlab.commands.%s[1]()<CR>'
    vim.api.nvim_buf_set_keymap(0, "n", lhs, string.format(template, rhs), {noremap=true, silent=true})
  end

  set_keymap("<localleader>bn", "TexlabBuild")
  set_keymap("<localleader>fs", "TexlabForward")
  set_keymap("<localleader>sl", "TexlabLog")

  -- improve completion for labels which often have a prefix like 'sec:'
  vim.opt.iskeyword:append{":"}

  vim.b.did_user_ftplugin = true
end
