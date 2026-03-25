--[[
  "Unwrap" mails written with aerc as an alternative to "format=flowed"
  (see http://www.mutt.org/doc/manual/#text-flowed).
--]]

if not vim.b.did_user_ftplugin then
  local cmd = "/usr/lib/aerc/filters/wrap"
  vim.opt_local.formatoptions:append("w")

  if vim.env.AERC_ACCOUNT then
    vim.api.nvim_create_autocmd("BufWrite", {
      group = vim.api.nvim_create_augroup("user_mail", {clear = true}),
      buffer = vim.api.nvim_get_current_buf(),
      callback = function()
        local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
        local output = vim.fn.system(("%s -w %u"):format(cmd, 2 ^ 32), text)

        if vim.v.shell_error == 0 then
          vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n", { plain = true }))
        else
          vim.notify(output, vim.log.levels.ERROR)
        end
      end,
    })
  end

  vim.b.did_user_ftplugin = true
end
