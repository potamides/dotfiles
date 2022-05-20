--[[
  Small modifications to the gruvbox colorscheme.
--]]

local au = require("au")

-- load base gruvbox colorscheme installed as library with packer
vim.cmd("runtime! library/gruvbox.vim")

-- change some diagnostic and spelling highlight groups
vim.api.nvim_set_hl(0, "DiagnosticHint", {link = "GruvboxPurple"})
vim.api.nvim_set_hl(0, "DiagnosticSignHint", {link = "GruvboxPurpleSign"})
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", {link = "GruvboxPurpleUnderline"})

vim.api.nvim_set_hl(0, "SpellBad", {link = "GruvboxBlueUnderline"})
vim.api.nvim_set_hl(0, "SpellCap", {link = "GruvboxOrangeUnderline"})
vim.api.nvim_set_hl(0, "SpellRare", {link = "GruvboxGreenUnderline"})

-- slightly adapt lightline tabline colors
local lightline_patch_colorscheme = au("lightline_patch_colorscheme")

function lightline_patch_colorscheme.VimEnter()
  if vim.g.loaded_lightline and vim.tbl_get(vim.g, "lightline", "colorscheme") == "gruvbox" then
    local palette = vim.g["lightline#colorscheme#gruvbox#palette"]
    if palette then
      palette.tabline.middle = palette.normal.middle
      palette.tabline.right = palette.tabline.left
      vim.g["lightline#colorscheme#gruvbox#palette"] = palette
      vim.fn['lightline#colorscheme']()
    end
  end
end
