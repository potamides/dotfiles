--[[
  Remove the repl window from the buffer list and close nvim when repl is last
  window. Also set some options.
]]
if not vim.b.did_user_ftplugin then
  -- same behavior like quickfix window
  vim.cmd.runtime{"ftplugin/qf.lua", bang = true}

  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup(vim.bo.filetype, {clear = false}),
    buffer = 0,
    once = true,
    callback = function()
      vim.opt_local.colorcolumn = ""
      vim.opt_local.fillchars = "eob: "
      vim.opt_local.spell = false
      vim.opt_local.winfixheight=true
      vim.opt_local.list = false
      vim.opt_local.textwidth = 0

      -- set same options as dap-terminal
      vim.opt_local.signcolumn = "no"
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
    end
  })
end
