--[[
  Small modifications to the gruvbox colorscheme.
--]]

-- load base gruvbox colorscheme installed as library with packer
vim.cmd("runtime! library/gruvbox.vim")

-- change some diagnostic and spelling highlight groups
-- lua syntax api is still work in progress (see https://github.com/neovim/neovim/issues/9876)
vim.cmd([[
  hi! link DiagnosticHint GruvboxPurple
  hi! link DiagnosticSignHint GruvboxPurpleSign
  hi! link DiagnosticUnderlineHint GruvboxPurpleUnderline

  hi! link SpellBad GruvboxBlueUnderline
  hi! link SpellCap GruvboxOrangeUnderline
  hi! link SpellRare GruvboxGreenUnderline
]])

-- slightly adapt lightline tabline colors
function vim.fn.patch_lightline_colorscheme()
  if vim.g.loaded_lightline and vim.fn.get(vim.g.lightline or {}, "colorscheme") == "gruvbox" then
    local palette = vim.g["lightline#colorscheme#gruvbox#palette"]
    if palette then
      palette.tabline.middle = palette.normal.middle
      palette.tabline.right = palette.tabline.left
      vim.g["lightline#colorscheme#gruvbox#palette"] = palette
      vim.fn['lightline#colorscheme']()
    end
  end
end

vim.cmd([[
  augroup lightline_patch_colorscheme
    autocmd!
    autocmd VimEnter * call v:lua.vim.fn.patch_lightline_colorscheme()
  augroup END
]])
