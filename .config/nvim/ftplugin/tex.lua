--[[
  Setup texlab language server.
--]]

if not vim.b.did_user_ftplugin then
  local texlab = require("lspconfig").texlab
  local windows = require("lspconfig/ui/windows")
  local util = require('lspconfig/util')

  if not texlab.manager then
    texlab.setup{
      root_dir = function(f)
        return util.root_pattern("latexmkrc")(f) or util.find_git_ancestor(f) or util.path.dirname(f)
      end,
      settings = {
        texlab = {
          build = {
            args = {"-interaction=nonstopmode", "-synctex=1", "%f"},
            forwardSearchAfter = true
          },
          forwardSearch = {
            executable = "qpdfview",
            args = {"--unique", "--instance", "tex_" .. vim.fn.localtime(), "%p#src:%f:%l:1"}
          },
          chktex = {
            onEdit = true,
            onOpenAndSave = true
          }
        }
      },
      on_new_config = function(config, root_dir)
        local build_dir = root_dir .. "/build"

        if vim.fn.isdirectory(build_dir) == 1 then
          config.settings.texlab.auxDirectory = build_dir
        end

        config.commands = {
          TexlabLog = {
            function()
              local lines = {}

              for _, file in ipairs(vim.fn.glob(build_dir .. "/*.log\\|blg", false, true)) do
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
      end
    }

    if not (texlab.autostart == false) then
      texlab.manager.try_add_wrapper()
    end
  end

  vim.api.nvim_buf_set_keymap(0, "n", "<localleader>bn", '<cmd>TexlabBuild<cr>', {silent=true})
  vim.api.nvim_buf_set_keymap(0, "n", "<localleader>fs", '<cmd>TexlabForward<cr>', {silent=true})
  vim.api.nvim_buf_set_keymap(0, "n", "<localleader>sl", '<cmd>TexlabLog<cr>', {silent=true})

  -- improve completion for labels which often have a prefix like 'sec:'
  vim.opt.iskeyword:append{":"}

  vim.b.did_user_ftplugin = true
end
