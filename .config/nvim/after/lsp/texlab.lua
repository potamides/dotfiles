--[[
  Set up texlab language server and integrate it with python virtual envs for
  building graphics (minted, matplotlib, etc)
--]]

-- Find python virtualenvs. This should normally be done in on_new_config to
-- start from the correct root dir but nvim doesn't support that yet:
-- https://github.com/neovim/neovim/issues/32287
local venv_bin, path, venv = vim.fs.root(0, ".venv/bin/python")
if venv_bin then
  path = ("%s:%s"):format(venv_bin, vim.env.PATH)
  venv = vim.fs.dirname(venv_bin)
end

local log_win = -1
local function TexlabLog(aux_dir)
  local lines = {}

  for _, file in ipairs(vim.fn.glob(aux_dir .. "/*.log\\|blg", false, true)) do
    vim.list_extend(lines, vim.fn.readfile(file))
  end

  if not vim.tbl_isempty(lines) then
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
    vim.api.nvim_set_option_value("modifiable", false, {buf = buf})
    vim.api.nvim_set_option_value("filetype", "plaintex", {buf = buf})
    if not vim.api.nvim_win_is_valid(log_win) then
      log_win = vim.api.nvim_open_win(buf, true, {split="right"})
    else
      vim.api.nvim_win_set_buf(log_win, buf)
    end
  end
end

return {
  cmd_env = {
    PATH = path,
    VIRTUAL_ENV = venv,
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
  on_init = function(client)
    local augroup = vim.api.nvim_create_augroup(("%s_%d"):format(client.name, client.id), {})

    local function on_attach(bufnr, aux_dir)
      vim.api.nvim_buf_create_user_command(
        bufnr,
        "TexlabLog",
        function() TexlabLog(vim.fs.joinpath(client.config.root_dir or ".", aux_dir)) end,
        {desc = "Show content of log files in a floating window."}
      )

      -- define some keybindings for convenient access to some lsp commands
      vim.keymap.set("n", "<localleader>bn", '<cmd>LspTexlabBuild<cr>', {silent = true, buffer = bufnr})
      vim.keymap.set("n", "<localleader>fs", '<cmd>LspTexlabForward<cr>', {silent = true, buffer = bufnr})
      vim.keymap.set("n", "<localleader>sl", '<cmd>TexlabLog<cr>', {silent = true, buffer = bufnr})
      vim.keymap.set("n", "<localleader>ce", '<cmd>LspTexlabChangeEnvironment<cr>', {silent = true, buffer = bufnr})
      vim.keymap.set("n", "<localleader>cl", '<cmd>LspTexlabCleanAuxiliary<cr>', {silent = true, buffer = bufnr})
      vim.keymap.set("n", "<localleader>cn", '<cmd>LspTexlabCancelBuild<cr>', {silent = true, buffer = bufnr})
    end

    local function on_dir_report(obj)
      -- find actual aux_dir following latexmk approach: https://github.com/latex-lsp/texlab/pull/968
      local dirs = {obj.stdout:match("Normalized aux dir, out dir, out2 dir:%s-'(.-)', '(.-)', '(.-)'")}
      -- even when using --dir-report-only latexmk still creates these
      -- directories which might not be what we want
      for _, path in ipairs(dirs) do
        if vim.fs.abspath(path) ~= vim.fs.abspath(client.config.root_dir or ".") then
          os.remove(path)
        end
      end

      -- help texlab find the compiled pdf for forward search
      client.config.settings.texlab.build.pdfDirectory = dirs[3]
      client.notify("workspace/didChangeConfiguration",
        {settings = client.config.settings}
      )

      vim.api.nvim_create_autocmd("LspAttach", {
        group = augroup,
        callback = function(args)
          if args.data.client_id == client.id then
            on_attach(args.buf, dirs[1])
          end
        end
      })

      -- manually run for already attached buffers
      for buf, _ in ipairs(client.attached_buffers) do
        on_attach(buf, dirs[1])
      end

      vim.api.nvim_create_autocmd("LspDetach", {
        group = augroup,
        callback = function(args)
          if args.data.client_id == client.id then
            vim.api.nvim_clear_autocmds{group=augroup}
          end
        end,
      })
    end

    vim.system(
      {client.config.settings.texlab.build.executable, "-dir-report-only"},
      {text = true},
      vim.schedule_wrap(on_dir_report)
    )
  end
}
