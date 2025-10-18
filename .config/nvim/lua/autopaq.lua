--[[
  Lightweight wrapper around paq-nvim. It simply makes sure that paq-nvim is
  installed, if not it downloads it and installs packages which makes running
  neovim for the first time a pleasant experience. It also adds support for an
  optional "patch" field which can contain links to patches that are applied to
  downloaded packages.
--]]

local function require_and_install_paq()
  vim.notify("Installing paq-nvim plugin manager...")
  local install_path = vim.fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
  vim.fn.system{'git', 'clone', '--depth', 1, 'https://github.com/savq/paq-nvim', install_path}
  vim.cmd.packadd("paq-nvim")
  return require("paq")
end

local already_installed, paq = xpcall(function() return require("paq") end, require_and_install_paq)

local function get_info(name)
  for _, info in pairs(require("paq").query("installed")) do
    if vim.endswith(name, info.name) then
      return info
    end
  end
end

local function register_patches(plugins)
  for _, plugin in pairs(plugins) do
    if plugin.patches and not plugin.run then
      function plugin.build()
        local info = get_info(plugin[1])
        for _, uri in ipairs(plugin.patches or {}) do
          uri = uri:match("^https?://") and uri or ((info.url):match(".-[^:/]/") .. uri)
          local patch = vim.system{"curl", "-L", uri}:wait().stdout
          vim.system({"git", "apply"}, {cwd = info.dir, stdin = patch}):wait()
        end
        vim.system({"git", "config", "merge.autoStash"}, {cwd = info.dir}):wait()
      end
    end
  end

  return plugins
end

function paq.bootstrap(plugins)
  paq(register_patches(plugins))
  if not already_installed then
    vim.notify("Installing plugins...")
    -- reload packages after VimEnter to take user configuration into account
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        for _, plugin in pairs(plugins) do
          local name = vim.tbl_get(plugin, 1) or plugin
          vim.g["loaded_" .. vim.fs.basename(name):gsub("-", "_")] = nil
        end
        vim.cmd.packloadall{bang=true}
      end
    })
    -- no way to run paq synchronously, so we wait for the 'done' event
    local paq_done = false
    vim.api.nvim_create_autocmd("User", {
      pattern = "PaqDoneInstall",
      once = true,
      callback = function()
        paq_done = true
      end
    })
    paq.install()
    while not paq_done do
      vim.wait(1000)
    end
  end
  return paq
end

return setmetatable({}, {
  __call = function(_, ...) paq.bootstrap(...) end,
  __index = paq
})
