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
    cmd_env = {
      -- trick to help neovim-remote find this neovim instance
      NVIM_LISTEN_ADDRESS = vim.v.servername,
    },
    settings = {
      texlab = {
        build = {
          args = {"-interaction=nonstopmode", "-synctex=1", "-pv", "%f"},
          --forwardSearchAfter = true
        },
        forwardSearch = {
          executable = "qpdfview",
          args = {"--unique", "--instance", "pdf_" .. (vim.env.WINDOWID or ""), "%p#src:%f:%l:1"}
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
              local autocmd = au{once = true, buffer = info.bufnr, BufExit = {"BufHidden", "BufLeave"}}

              vim.api.nvim_buf_set_lines(info.bufnr, 0, -1, true, lines)
              vim.api.nvim_buf_set_option(info.bufnr, "modifiable", false)
              vim.keymap.set("n", "<esc>", "<cmd>bd<CR>", {noremap = true, buffer = info.bufnr})

              function autocmd.BufExit()
                pcall(vim.api.nvim_win_close, info.win_id, true)
              end
            end
          end,
          description = "Show content of log files in a floating window."
        },
        ChangeEnvironment = {
          function()
            vim.ui.input({prompt = 'New Name: '}, function(new_name)
              if not new_name or #new_name == 0 then
                return
              end

              local pos = vim.api.nvim_win_get_cursor(0)
              vim.lsp.buf.execute_command{
                command = "texlab.changeEnvironment",
                arguments = {{
                  textDocument = {uri = vim.uri_from_bufnr(0)},
                  position = {line = pos[1] - 1, character = pos[2]},
                  newName = new_name,
                }}
              }
            end)
          end,
          description = "Change the name of the inner-most environment."
        },
        CleanAuxiliary = {
          function()
              vim.lsp.buf.execute_command{
                command = "texlab.cleanAuxiliary",
                arguments = {{uri = vim.uri_from_bufnr(0)}},
              }
          end,
          description = "Remove the auxiliary files produced by compiling the specified LaTeX document."
        },
        CancelBuild = {
          function() vim.lsp.buf.execute_command{command = "texlab.cancelBuild"} end,
          description = "Cancel all currently active build requests."
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
        language = "auto", -- using "auto" also disables spell checking (for which we use vim)
        checkFrequency = "save",
        diagnosticSeverity = "hint",
        completionEnabled = true,
        --languageToolHttpServerUri = "https://api.languagetool.org",
        additionalRules = {
          motherTongue = "de-DE",
          languageModel = "/usr/share/ngrams", -- aur/languagetool-ngrams-{en,de,..}
          word2VecModel = "/usr/share/word2vec", -- aur/languagetool-word2vec-{en,de,..}
          enablePickyRules = true
        },
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
    },
  }

  local function ltex_command(setting, id)
    return function(command, ctx)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        local values = client.config.settings.ltex[setting] or {}

        for lang, new in pairs(command.arguments[1][id]) do
            values[lang] = vim.list_extend(values[lang] or {}, new)
        end

        client.config.settings.ltex[setting] = values
        return client.notify("workspace/didChangeConfiguration", client.config.settings)
    end
  end

  -- implement ltex commands which must be handled by neovim
  vim.lsp.commands["_ltex.hideFalsePositives"] = ltex_command("hiddenFalsePositives", "falsePositives")
  vim.lsp.commands["_ltex.disableRules"] = ltex_command("disabledRules", "ruleIds")
  vim.lsp.commands["_ltex.addToDictionary"] = ltex_command("dictionary", "words")

  -- define some keybindings for convenient access to some lsp commands
  vim.keymap.set("n", "<localleader>bn", '<cmd>TexlabBuild<cr>', {silent = true, buffer = true})
  vim.keymap.set("n", "<localleader>fs", '<cmd>TexlabForward<cr>', {silent = true, buffer = true})
  vim.keymap.set("n", "<localleader>sl", '<cmd>TexlabLog<cr>', {silent = true, buffer = true})
  vim.keymap.set("n", "<localleader>ce", '<cmd>ChangeEnvironment<cr>', {silent = true, buffer = true})
  vim.keymap.set("n", "<localleader>cl", '<cmd>CleanAuxiliary<cr>', {silent = true, buffer = true})
  vim.keymap.set("n", "<localleader>cn", '<cmd>CancelBuild<cr>', {silent = true, buffer = true})
  vim.keymap.set("n", "<localleader>lt", '<cmd>LspStart ltex<cr>', {silent = true, buffer = true})

  -- in insert mode do not break a line which already was longer than 'textwidth'
  vim.opt_local.formatoptions:append{
    l = true,
  }

  vim.b.did_user_ftplugin = true
end
