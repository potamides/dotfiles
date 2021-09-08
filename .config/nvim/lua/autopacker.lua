---@diagnostic disable: undefined-global

--[[
  Lightweight wrapper around packer.nvim. It simply makes sure that packer.nvim
  is installed, if not it downloads it and syncs packages which makes running
  neovim for the first time a pleasant experience.
--]]

local installed, packer = xpcall(function() return require("packer") end, function()
  local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  vim.fn.system{'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path}
  vim.cmd('packadd packer.nvim')
  return require("packer")
end)

function packer.autostartup(plugins)
  packer.startup(plugins)
  if not installed then
    packer.sync()
    -- no option yet to run packer synchronously
    while not packer_plugins do
      vim.wait(1000)
    end
  end
  return packer
end

return packer

