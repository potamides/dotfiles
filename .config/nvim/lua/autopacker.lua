---@diagnostic disable: undefined-global

--[[
  Lightweight wrapper around packer.nvim. It simply makes sure that packer.nvim
  is installed, if not it downloads it and syncs packages which makes running
  neovim for the first time a pleasant experience.
--]]

local function require_and_install_packer()
  local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  vim.fn.system{'git', 'clone', '--depth', 1, 'https://github.com/wbthomason/packer.nvim', install_path}
  vim.cmd('packadd packer.nvim')
  return require("packer")
end

local already_installed, packer = xpcall(function() return require("packer") end, require_and_install_packer)
local plugin_utils = require("packer.plugin_utils")
local load_plugin = plugin_utils.load_plugin

-- Monkey patch plugin loading method. By default packer sources plugins after
-- installing them. This is fine when this happens after VimEnter, which is
-- usually the case, however, here we install packages while loading the vimrc,
-- and loading plugins before this is finished can lead to complications.
-- Because of this we add a check to allow manual loading of plugins only after
-- VimEnter. Ignoring plugin loading requests until then should be fine since
-- vim sources plugins on its own after loading the vimrc, anyway.
function plugin_utils.load_plugin(plugin)
  if vim.v.vim_did_enter == 1 then
    load_plugin(plugin)
  elseif not plugin.opt then
    vim.o.runtimepath = vim.o.runtimepath .. ',' .. plugin.install_path
  end
end

function packer.autostartup(plugins)
  packer.startup(plugins)
  if not already_installed then
    packer.sync()
    -- no option yet to run packer synchronously
    while not packer_plugins do
      vim.wait(1000)
    end
  end
  return packer
end

return packer
