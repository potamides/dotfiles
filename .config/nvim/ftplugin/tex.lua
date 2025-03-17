--[[
  Setup texlab language server for LaTeX editing and integrate ltex language
  server for optional grammar, style and spell checking.
--]]

if not vim.b.did_user_ftplugin then
  local lsputils = require("lsputils")
  local render = require("gp.render")
  local configs = require("lspconfig.configs")

  lsputils.texlab.setup{
    cmd_env = {
      -- trick to help neovim-remote find this neovim instance
      NVIM_LISTEN_ADDRESS = vim.v.servername,
      -- nicer formatting of logs
      max_print_line = 1000
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
      local function TexlabLog(aux_dir)
        local lines = {}

        for _, file in ipairs(vim.fn.glob(aux_dir .. "/*.log\\|blg", false, true)) do
          vim.list_extend(lines, vim.fn.readfile(file))
        end

        if not vim.tbl_isempty(lines) then
          local function size_func(w, h)
            return .8 * w, .7 * h, (.3 * h) * .4, (.2 * w) * .5
          end

          local buf = render.popup(nil, "Texlab Log", size_func, {on_leave = true, escape = true})
          vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
          vim.api.nvim_set_option_value("modifiable", false, {buf = buf})
          vim.api.nvim_set_option_value("filetype", "plaintex", {buf = buf})
        end
      end

      vim.system(
        {config.settings.texlab.build.executable, "-dir-report-only"},
        {text = true},
        vim.schedule_wrap(function(obj)
          -- find actual aux_dir following latexmk approach: https://github.com/latex-lsp/texlab/pull/968
          local aux_dir, out_dir = obj.stdout:match("Normalized aux dir and out dir: '(.-)', '(.-)'")
          -- even when using --dir-report-only latexmk still creates these
          -- directories which might not be what we want
          for _, path in ipairs{aux_dir, out_dir} do
            os.remove(path)
          end
          vim.api.nvim_create_user_command(
            "TexlabLog",
            function() TexlabLog(vim.fs.joinpath(root_dir, aux_dir)) end,
            {desc = "Show content of log files in a floating window."}
          )
        end)
      )

      -- also find python virtualenvs (for minted, matplotlib, etc)
      local venv = vim.fn.globpath(root_dir, ".*venv*\\|*venv*", nil, true)[1]
      if venv then
        config.cmd_env = {
          PATH = ("%s/bin:%s"):format(venv, vim.env.PATH),
          VIRTUAL_ENV = venv,
        }
      end
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
  vim.keymap.set("n", "<localleader>ce", '<cmd>TexlabChangeEnvironment<cr>', {silent = true, buffer = true})
  vim.keymap.set("n", "<localleader>cl", '<cmd>TexlabCleanAuxiliary<cr>', {silent = true, buffer = true})
  vim.keymap.set("n", "<localleader>cn", '<cmd>TexlabCancelBuild<cr>', {silent = true, buffer = true})
  vim.keymap.set("n", "<localleader>lt", '<cmd>LspStart ltex<cr>', {silent = true, buffer = true})

  -- in insert mode do not break a line which already was longer than 'textwidth'
  vim.opt_local.formatoptions:append{
    l = true,
  }

  vim.b.did_user_ftplugin = true
end
