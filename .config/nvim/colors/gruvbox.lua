---@diagnostic disable: undefined-global

--[[
  Small modifications to the gruvbox colorscheme.
--]]

local lush = require("lush")
local gruvbox = require("gruvbox")

-- slightly adapt lightline colorscheme
local palette = vim.g["lightline#colorscheme#gruvbox#palette"]
palette.tabline.middle = palette.normal.middle
vim.g["lightline#colorscheme#gruvbox#palette"] = palette

lush(lush.extends{gruvbox}.with(function()
  return {
    -- use same spelling highlighting as original gruvbox colorscheme
    SpellCap {gruvbox.GruvboxRedUnderline},
    SpellBad {gruvbox.GruvboxBlueUnderline},
    SpellLocal {gruvbox.GruvboxAquaUnderline},
    SpellRare {gruvbox.GruvboxPurpleUnderline},

    -- use same error highlighting as original gruvbox colorscheme
    Error {gruvbox.GruvboxRed, gui = "bold,inverse"},

    -- prevent collision with colors used by gitsigns
    LspDiagnosticsDefaultHint {gruvbox.GruvboxPurple},
    LspDiagnosticsSignHint {gruvbox.GruvboxPurpleSign},
    LspDiagnosticsUnderlineHint {gruvbox.GruvboxPurpleUnderline},
    LspDiagnosticsFloatingHint {gruvbox.GruvboxPurple},
    LspDiagnosticsVirtualTextHint {gruvbox.GruvboxPurple}
  }
end))
