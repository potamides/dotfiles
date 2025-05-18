--[[
  LaTeX-specific options and mappings.
--]]

if not vim.b.did_user_ftplugin then
  local function ltex_toggle()
    while true do
      local client_id = vim.lsp.start(vim.lsp.config.ltex_plus)
      coroutine.yield(client_id)
      if client_id then
        coroutine.yield(vim.lsp.stop_client(client_id))
      end
    end
  end

  -- keybinding to toggle ltex lsp (manual start required)
    vim.keymap.set("n", "<localleader>lt", coroutine.wrap(ltex_toggle), {silent = true, buffer = true})

  -- in insert mode do not break a line which already was longer than 'textwidth'
  vim.opt_local.formatoptions:append{
    l = true,
  }

  vim.b.did_user_ftplugin = true
end
