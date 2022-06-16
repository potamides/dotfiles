--[[
  Setup texlab language server for LaTeX editing and integrate ltex language
  server for optional grammar, style and spell checking.
--]]

if not vim.b.did_user_ftplugin then
  local lsputils = require("lsputils")
  local windows = require("lspconfig.ui.windows")
  local configs = require("lspconfig.configs")
  local au = require("au")

  lsputils.texlab.setup{
    settings = {
      texlab = {
        build = {
          args = {"-interaction=nonstopmode", "-synctex=1", "-pv", "%f"},
          --forwardSearchAfter = true
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
    on_new_config = function(config, root_dir)
      -- FIXME: this can fail on the first run when "build" doesn't yet exit
      local build_dir = vim.fn.globpath(root_dir, "build", nil, true)[1] or root_dir
      config.settings.texlab.auxDirectory = build_dir

      config.commands = {
        TexlabLog = {
          function()
            local lines = {}

            for _, file in ipairs(vim.fn.glob(build_dir .. "/*.log\\|blg", false, true)) do
              vim.list_extend(lines, vim.fn.readfile(file))
            end

            if not vim.tbl_isempty(lines) then
              local info = windows.percentage_range_window(0.8, 0.7)
              local autocmd = au()({"BufHidden", "BufLeave"}, {once = true, buffer = info.bufnr})

              vim.api.nvim_buf_set_lines(info.bufnr, 0, -1, true, lines)
              vim.api.nvim_buf_set_option(info.bufnr, "modifiable", false)
              vim.keymap.set("n", "<esc>", "<cmd>bd<CR>", {noremap = true, buffer = info.bufnr})

              function autocmd.handler()
                pcall(vim.api.nvim_win_close, info.win_id, true)
              end
            end
          end,
          description = "Show content of log files in a floating window."
        }
      }
    end
  }

  -- Configure ltex so that it is not started automatically. Instead, it can be
  -- started manually if needed (see keybindings below).
  lsputils.ltex.setup{
    autostart = false,
    -- make ltex root directory the same as texlab
    root_dir = configs.texlab.get_root_dir,
    settings = {
      ltex = {
        language = "en-US",
        checkFrequency = "save",
        diagnosticSeverity = "hint",
        completionEnabled = true,
        additionalRules = {
          motherTongue = "de-DE",
          languageModel = "/usr/share/ngrams", -- aur/languagetool-ngrams-{en,de,..}
          word2VecModel = "/usr/share/word2vec", -- aur/languagetool-word2vec-{en,de,..}
          enablePickyRules = true
        }
      }
    },
    handlers = {
      -- report ltex diagnostics similar to internal spell checking
      ["textDocument/publishDiagnostics"] = vim.lsp.with(
         vim.lsp.diagnostic.on_publish_diagnostics, {
           underline = true,
           virtual_text = false,
           signs = false
         }
       )
    }
  }

  -- define some keybindings for convenient access to some lsp commands
  vim.keymap.set("n", "<localleader>bn", '<cmd>TexlabBuild<cr>', {silent = true, buffer = true})
  vim.keymap.set("n", "<localleader>fs", '<cmd>TexlabForward<cr>', {silent = true, buffer = true})
  vim.keymap.set("n", "<localleader>sl", '<cmd>TexlabLog<cr>', {silent = true, buffer = true})
  vim.keymap.set("n", "<localleader>lt", '<cmd>LspStart ltex<cr>', {silent = true, buffer = true})

  -- in insert mode do not break a line which already was longer than 'textwidth'
  vim.opt_local.formatoptions:append{
    l = true,
  }

  vim.b.did_user_ftplugin = true
end
