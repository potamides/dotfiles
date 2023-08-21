if not vim.b.did_user_ftplugin then
-- when python is installed use it for formatting with 'gq' operator
  if vim.fn.executable(vim.g.python3_host_prog) == 1 then
    vim.opt_local.formatprg = vim.g.python3_host_prog .. " -m json.tool"
  end
  vim.b.did_user_ftplugin = true
end
