--[[
  Main Neovim configuration. Tries to be mostly language agnostic. Language
  specific and buffer-local options are instead moved to corresponding
  ftplugins.
--]]

-------------------------------------------------------------------------------
-- {{{ Generic Configuration
-------------------------------------------------------------------------------

-- Options
-------------------------------------------------------------------------------

-- smart search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- syntax-based folding
vim.opt.foldlevel = 99
vim.opt.foldmethod = "syntax"

-- tabs are 2 spaces
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- line break configuration
vim.opt.textwidth = 79
vim.opt.colorcolumn = {80, 120}
vim.opt.breakindent = true

-- list mode for horizontal scrolling
vim.opt.list = true
vim.opt.listchars.precedes = "<"
vim.opt.listchars.extends = ">"

-- setup built-in completion
vim.opt.omnifunc = 'v:lua.vim.lsp.omnifunc'
vim.opt.completeopt:append{"menuone", "noinsert"}

-- print line number in front of each line
vim.opt.number = true
vim.opt.relativenumber = true

-- spell checking
vim.opt.spell = true
vim.opt.spelllang = {"en_us", "de_de", "cjk"}

-- mouse and clipboard integration
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"

vim.opt.termguicolors = true   -- 24-bit RGB color in the TUI
vim.opt.undofile = true        -- persistent undo history
vim.opt.showmode = false       -- do not show mode message on last line
vim.opt.hidden = true          -- switch buffers without having to save changes
vim.opt.joinspaces = false     -- insert one space when joining two sentences
vim.opt.inccommand = "nosplit" -- show incremental changes of commands such as search & replace
vim.opt.virtualedit = "block"  -- virtual editing in virutal block mode
vim.opt.shortmess:append("I")  -- don't give intro message when starting vim

-- Variables
-------------------------------------------------------------------------------

-- define leaders for use in keybindings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- syntax related global variables
vim.g.sh_no_error = true
vim.g.readline_has_bash = true
vim.g.tex_fold_enabled = true
vim.g.tex_flavor = "latex"
vim.g.markdown_fenced_languages = {"sh", "python", "lua"}

vim.g.netrw_browsex_viewer = "xdg-open"        -- define opener for 'gx' mapping
vim.g.python3_host_prog = "/usr/bin/python3"   -- use system python (useful when working with virualenvs)
vim.g.vga_compatible = vim.env.TERM == "linux" -- VGA textmode fallback (with CP437 character set) for legacy terminals

-- Automatic commands
-------------------------------------------------------------------------------

-- unfortunately augroups and autocommands do not have a lua interface yet
-- (see https://github.com/neovim/neovim/pull/14661)

-- jump to last position when reopening file
vim.cmd([[
  augroup last_position_jump
    autocmd!
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  augroup END
]])

-- briefly highlight a selection on yank
vim.cmd([[
  augroup yank_highlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup END
]])

-- enter insert mode when opening a terminal
vim.cmd([[
  augroup term_enter
    autocmd!
    autocmd TermOpen * startinsert
  augroup END
]])

-- when a terminal window is narrow (below 80 lines) disable text wrapping
vim.cmd([[
  augroup auto_wrap
    autocmd!
    autocmd VimResized,VimEnter * if (&columns < 80) | set nowrap | else | set wrap | endif
  augroup END
]])

-- automatically toggle between relative and absolute line numbers depending on mode
vim.cmd([[
  augroup number_toggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
  augroup END
]])

-- disable preview window when completion is finished
vim.cmd([[
  augroup preview_close
    autocmd!
    autocmd CompleteDone * if pumvisible() == 0 | pclose | endif
  augroup END
]])

-- Commands
-------------------------------------------------------------------------------

-- similar to autocmds, the lua interface for commands is also still work in progress
-- (see https://github.com/neovim/neovim/pull/11613)

-- pretty print lua code with :Print <code>
vim.cmd([[command! -complete=lua -nargs=* Print :lua print(vim.inspect(<args>))]])

vim.cmd([[command! Config :e $MYVIMRC]])       -- open config file with :Config
vim.cmd([[command! Reload :luafile $MYVIMRC]]) -- reload config file with :Reload

-- Mappings
-------------------------------------------------------------------------------
local function set_keymap(lhs, rhs, opts)
  vim.api.nvim_set_keymap('n', lhs, rhs, vim.tbl_extend("error", {noremap=true, silent=true}, opts or {}))
end

-- navigate buffers like tabs (gt & gT)
set_keymap("gb", '"<cmd>bnext " . v:count1 . "<CR>"', {expr = true})
set_keymap("gB", '"<cmd>bprev " . v:count1 . "<CR>"', {expr = true})

-- language server mappings
set_keymap('gD',         '<cmd>lua vim.lsp.buf.declaration()<CR>')
set_keymap('gd',         '<cmd>lua vim.lsp.buf.definition()<CR>')
set_keymap('K',          '<cmd>lua vim.lsp.buf.hover()<CR>')
set_keymap('gi',         '<cmd>lua vim.lsp.buf.implementation()<CR>')
set_keymap('<C-k>',      '<cmd>lua vim.lsp.buf.signature_help()<CR>')
set_keymap('<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>')
set_keymap('<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>')
set_keymap('<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
set_keymap('<leader>D',  '<cmd>lua vim.lsp.buf.type_definition()<CR>')
set_keymap('<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
set_keymap('<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
set_keymap('gr',         '<cmd>lua vim.lsp.buf.references()<CR>')
set_keymap('<leader>e',  '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
set_keymap('[d',         '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
set_keymap(']d',         '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
set_keymap('<leader>q',  '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>')
set_keymap('<leader>f',  '<cmd>lua vim.lsp.buf.formatting()<CR>')

-- Language Server Client
-------------------------------------------------------------------------------
local prefix = "LspDiagnosticsSign"

vim.fn.sign_define{
  { name = prefix .. "Error",       text = "▌", texthl = prefix .. "Error"},
  { name = prefix .. "Warning",     text = "▌", texthl = prefix .. "Warning"},
  { name = prefix .. "Hint",        text = "▌", texthl = prefix .. "Hint"},
  { name = prefix .. "Information", text = "▌", texthl = prefix .. "Information"}
}

-- }}}
-------------------------------------------------------------------------------
-- {{{ Plugin-Specific Configuration
-------------------------------------------------------------------------------
local packer = require("autopacker")

-- small, custom wrapper around packer.startup which installs packer
-- automatically when it is missing
packer.autostartup{{
  "wbthomason/packer.nvim",
  "unblevable/quick-scope",
  "DarwinSenior/nvim-colorizer.lua",
  "neovim/nvim-lspconfig",
  {
    "lewis6991/gitsigns.nvim",
    requires = "nvim-lua/plenary.nvim"
  },
  {
    "itchyny/lightline.vim",
    requires = {
      "mgee/lightline-bufferline",
      "ryanoasis/vim-devicons"
    }
  },
  {
    "ellisonleao/gruvbox.nvim",
    requires = "rktjmp/lush.nvim",
    run = "git sparse-checkout set lua"
  }
}}

-- Gruvbox
-------------------------------------------------------------------------------
vim.g.gruvbox_contrast_dark = "medium"
vim.g.gruvbox_italic = true

-- only enable this color scheme when supported by terminal
if not vim.g.vga_compatible then
  vim.cmd("colorscheme gruvbox")
end

-- Lightline
-------------------------------------------------------------------------------
local function vga_fallback(regular, fallback)
  return vim.g.vga_compatible and fallback or regular
end

vim.g.lightline = {
  -- use same colorscheme as the one loaded by neovim with sensible fallback
  colorscheme = vim.g.colors_name or "16color",
  -- register new components
  component = {
    lineinfo     = vga_fallback("", "↕") .. " %3l:%-2c",
    fileencoding = '%{v:lua.vim.fn.lightline_narrow() ? "" : &fenc!=#""?&fenc:&enc}',
    fileformat   = '%{v:lua.vim.fn.lightline_narrow() ? "" : &ff}',
  },
  component_function = {
    filename  = "g:lightline_filename",
    gitbranch = "g:lightline_gitbranch",
    warnings  = "g:lightline_warnings",
    errors    = "g:lightline_errors"
  },
  component_expand = {
    buffers = "lightline#bufferline#buffers",
    rtabs   = "{ -> reverse(lightline#tabs())}"
  },
  -- adjust components
  component_type = {
    buffers = "tabsel",
    rtabs   = "tabsel"
  },
  component_raw  = {
    buffers = true
  },
  component_visible_condition = {
    fileencoding = "!v:lua.vim.fn.lightline_narrow()",
    fileformat   = "!v:lua.vim.fn.lightline_narrow()",
  },
  -- modify statusline and tabline
  separator    = {left = "▌", right = "▐"},
  subseparator = {left = "│", right = "│"},
  active       = {left = {{"mode", "paste"}, {"filename"}, {"gitbranch", "errors", "warnings"}}},
  tabline      = {left = {{"buffers"}}, right = {{"rtabs"}}},
  tab          = {active = {"tabnum"}, inactive = {"tabnum"}},
}

function vim.fn.lightline_narrow()
  return vim.fn.winwidth(0) < 95
end

function vim.g.lightline_filename()
  local filename = vim.fn.expand("%:t", false, true)[1] or "*"
  local edit, lock = vga_fallback(" ✎", " +"), vga_fallback(" ", " -")
  local suffix = (vim.o.modifiable and not vim.o.readonly) and (vim.o.modified and edit or "") or lock
  return vga_fallback(vim.fn.WebDevIconsGetFileTypeSymbol(), "≡") .. " " .. filename .. suffix
end

function vim.g.lightline_gitbranch()
  if vim.fn.lightline_narrow() then
    return ""
  else
    return vim.b.gitsigns_head and vga_fallback(" ", "↨ ") .. vim.b.gitsigns_head or ""
  end
end

function vim.g.lightline_errors()
    local errors = vim.lsp.diagnostic.get_count(0, "Error")
    return errors > 0 and vga_fallback(" ", "‼ ") .. errors or ""
end
function vim.g.lightline_warnings()
    local warnings = vim.lsp.diagnostic.get_count(0, "Warning")
    return warnings > 0 and vga_fallback(" ", "! ") .. warnings or ""
end

vim.g["lightline#bufferline#unicode_symbols"] = not vim.g.vga_compatible
vim.g["lightline#bufferline#enable_devicons"] = not vim.g.vga_compatible
vim.g["lightline#bufferline#clickable"]       = true

-- the minimum number of buffers & tabs needed to automatically show the tabline
vim.g["lightline#bufferline#min_buffer_count"] = 2
vim.g["lightline#bufferline#min_tab_count"]    = 2

-- update diagnostics information inside lightline
vim.cmd([[
  augroup lightline_diagnostics
    autocmd!
    autocmd User LspDiagnosticsChanged call lightline#update()
  augroup END
]])

-- Quick-Scope
-------------------------------------------------------------------------------
vim.cmd(string.format([[
  augroup qs_colors
    autocmd!
    autocmd ColorScheme * execute "highlight %s guisp=" . %s . " gui=bold,underline ctermfg=%d cterm=bold,underline"
    autocmd ColorScheme * execute "highlight %s guisp=" . %s . " gui=bold,underline ctermfg=%d cterm=bold,underline"
  augroup END
]], "QuickScopePrimary", "g:terminal_color_10", 10, "QuickScopeSecondary", "g:terminal_color_13", 13))

vim.g.qs_highlight_on_keys = {"f", "F", "t", "T"}

-- Gitsigns
-------------------------------------------------------------------------------
local gitsigns = require("gitsigns")

gitsigns.setup{
  signs = {
    add = { hl = "GitSignsAdd", text = "▌" },
    change = { hl = "GitSignsChange", text = "▌" },
    delete = { hl = "GitSignsDelete", text = vga_fallback("▁", "▼")},
    topdelete = { hl = "GitSignsDelete", text = vga_fallback("▔", "▲")},
    changedelete = { hl = "GitSignsChange", text = "▬" },
  }
}

-- Colorizer
------------------------------------------------------------------------------
local colorizer = require("colorizer")

-- colorize color specifications like '#aabbcc' in virtualtext
colorizer.setup(
  {'*'},
  {names = false, mode = 'virtualtext'}
)

-- Lsp-config
-------------------------------------------------------------------------------
local lspconfig = require('lspconfig')

-- debounce 'didChange' notifications to the server
lspconfig.util.default_config.flags = {debounce_text_changes = 150}

-- }}}
-- dnl vim: foldmethod=marker foldmarker=--\ {{{,--\ }}}
