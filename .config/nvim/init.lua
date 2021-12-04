--[[
  Main Neovim configuration. Aims to be mostly language agnostic. Code which is
  language specific and buffer-local was moved to corresponding ftplugins in
  the directory "ftplugin" instead. Also, larger chunks of coherent code were
  refactored into libraries in "lua" or plugins in "plugin" to not clutter the
  main configuration file.
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
vim.opt.foldmethod = "syntax"
vim.opt.foldlevel = 99

-- tabs are 2 spaces
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- line break configuration
vim.opt.textwidth = 79
vim.opt.colorcolumn = {80, 120}
vim.opt.breakindent = true

-- set list chars for horizontal scrolling
vim.opt.listchars:append{tab = "» ", precedes = "<", extends = ">"}
vim.opt.list = true

-- setup built-in completion
vim.opt.completeopt:append{"menuone", "noinsert"}
vim.opt.complete:remove{"t"}
vim.opt.omnifunc = 'v:lua.vim.lsp.omnifunc'             -- neovim internal lsp completion
vim.opt.completefunc = 'v:lua.vim.luasnip.completefunc' -- custom snippet completion defined in plugin/snipcomp.lua

-- print line numbers and highlight cursor line number
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

-- spell checking
vim.opt.spelllang = {"en_us", "de_de", "cjk"}
vim.opt.spell = true

-- mouse and clipboard integration
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"

-- set an alternative layout that can be switched to in insert mode with CTRL-^
vim.opt.keymap = "kana"
vim.opt.iminsert = 0

vim.opt.termguicolors = true   -- 24-bit RGB color in the TUI
vim.opt.undofile = true        -- persistent undo history
vim.opt.showmode = false       -- do not show mode message on last line
vim.opt.hidden = true          -- switch buffers without having to save changes
vim.opt.joinspaces = false     -- insert one space when joining two sentences
vim.opt.confirm = true         -- raise dialog asking to save changes when commands like ':q' fail
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
vim.g.tex_flavor = "latex"
vim.g.markdown_fenced_languages = {"sh", "python", "lua"}

-- setup netrw and viewer for 'gx' mapping
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browsex_viewer = "xdg-open"

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
    autocmd BufEnter,FocusGained,InsertLeave,TermLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
    autocmd BufLeave,FocusLost,InsertEnter,TermEnter,WinLeave   * if &nu                  | set nornu | endif
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

-- similar to autocmds, the lua interface of commands is also still work in progress
-- (see https://github.com/neovim/neovim/pull/11613)

-- pretty print lua code with :Print <code>
vim.cmd([[command! -complete=lua -nargs=* Print :lua print(vim.inspect(<args>))]])

-- open new terminal at the bottom of the current tab
vim.cmd([[command! -nargs=? Terminal :botright 12split | setlocal winfixheight | term <args>]])

vim.cmd([[command! Run :!"%:p"]])              -- Execute current file
vim.cmd([[command! Config :e $MYVIMRC]])       -- open config file with :Config
vim.cmd([[command! Reload :luafile $MYVIMRC]]) -- reload config file with :Reload

-- Mappings
-------------------------------------------------------------------------------
local opts = {noremap = true, silent = true}

local function keymap(...)
  vim.api[type(...) == "number" and "nvim_buf_set_keymap" or "nvim_set_keymap"](...)
end

-- navigate buffers like tabs (gt & gT)
keymap("n", "gb", '"<cmd>bnext " . v:count1 . "<cr>"', {expr = true, unpack(opts)})
keymap("n", "gB", '"<cmd>bprev " . v:count1 . "<cr>"', {expr = true, unpack(opts)})

-- language server mappings
local function lsp_mappings(_, buf)
  keymap(buf, "n", 'gd',         '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
  keymap(buf, "n", 'gD',         '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
  keymap(buf, "n", '<leader>gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
  keymap(buf, "n", '<leader>gt', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
  keymap(buf, "n", 'K',          '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  keymap(buf, "n", '<C-k>',      '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
  keymap(buf, "n", '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>', opts)
  keymap(buf, "n", '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>', opts)
  keymap(buf, "n", '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>', opts)
  keymap(buf, "n", '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  keymap(buf, "n", '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  keymap(buf, "n", '<leader>rf', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
  keymap(buf, "n", '<leader>ll', '<cmd>lua vim.diagnostic.setloclist()<cr>', opts)
  keymap(buf, "n", '<leader>ld', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
  keymap(buf, "n", '[d',         '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
  keymap(buf, "n", ']d',         '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
  keymap(buf, "n", '<leader>fm', '<cmd>lua vim.lsp.buf.formatting()<cr>', opts)
end

-- Language Server Client
-------------------------------------------------------------------------------
local prefix = "DiagnosticSign"

-- when not on the console set some nice lsp signs
if not vim.g.vga_compatible then
  vim.fn.sign_define{
    {name = prefix .. "Error", text = "▌", texthl = prefix .. "Error"},
    {name = prefix .. "Warn",  text = "▌", texthl = prefix .. "Warn"},
    {name = prefix .. "Hint",  text = "▌", texthl = prefix .. "Hint"},
    {name = prefix .. "Info",  text = "▌", texthl = prefix .. "Info"}
  }
end

-- }}}
-------------------------------------------------------------------------------
-- {{{ Plugin-Specific Configuration
-------------------------------------------------------------------------------
local packer = require("autopacker")

-- small, custom wrapper around packer.startup which installs packer
-- automatically when it is missing
packer.autostartup{
  {
    "wbthomason/packer.nvim",
    "unblevable/quick-scope",
    "DarwinSenior/nvim-colorizer.lua",
    "neovim/nvim-lspconfig",
    "tpope/vim-fugitive",
    {
      'nvim-telescope/telescope.nvim',
      requires = 'nvim-lua/plenary.nvim'
    },
    {
      "lewis6991/gitsigns.nvim",
      requires = "nvim-lua/plenary.nvim"
    },
    {
      "L3MON4D3/LuaSnip",
      requires = "rafamadriz/friendly-snippets"
    },
    {
      "itchyny/lightline.vim",
      requires = {
        "mgee/lightline-bufferline",
        "ryanoasis/vim-devicons"
      }
    },
    {"morhetz/gruvbox",
      -- install colorscheme as library so that we can easily patch it
      run = "git mv -k colors library"
    },
  },
  config = {
    git = {
      subcommands = {
        update = packer.config.git.subcommands.update .. " --autostash"
      }
    }
  }
}

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
local components = require("components")

local function vga_fallback(regular, fallback)
  return vim.g.vga_compatible and fallback or regular
end

-- signs for custom lightline components defined in lua/components.lua
components.setup{
  signs = {
    edit     = vga_fallback("✎", "+"),
    lock     = vga_fallback("", "-"),
    git      = vga_fallback("", "↨"),
    error    = vga_fallback("", "‼"),
    warning  = vga_fallback("", "!"),
    filetype = vga_fallback(vim.fn.WebDevIconsGetFileTypeSymbol, "≡"),
    spinner  = vga_fallback({'⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'}, {"-", "\\", "|", "/"})
  }
}

vim.g.lightline = {
  -- use same colorscheme as the one loaded by neovim with sensible fallback
  colorscheme = vim.g.colors_name or "16color",
  -- register new components
  component = {
    lineinfo     = vga_fallback("", "↕") .. " %3l:%-2c",
    fileencoding = string.format('%%{%s() ? "" : &fenc!=#""?&fenc:&enc}', components.string.is_narrow),
    fileformat   = string.format('%%{%s() ? "" : &ff}', components.string.is_narrow)
  },
  component_function = {
    filename  = components.string.filename,
    gitbranch = components.narrow.string.gitbranch,
    progress  = components.string.progress,
    warnings  = components.string.warnings,
    errors    = components.string.errors
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
  component_raw = {
    buffers = true
  },
  component_visible_condition = {
    fileencoding = string.format("!%s()", components.string.is_narrow),
    fileformat   = string.format("!%s()", components.string.is_narrow)
  },
  -- modify statusline and tabline
  separator    = {left = "▌", right = "▐"},
  subseparator = {left = "│", right = "│"},
  active       = {left = {{"mode", "paste"}, {"filename"}, {"progress", "gitbranch", "errors", "warnings"}}},
  tabline      = {left = {{"buffers"}}, right = {{"rtabs"}}},
  tab          = {active = {"tabnum"}, inactive = {"tabnum"}}
}

vim.g["lightline#bufferline#unicode_symbols"] = not vim.g.vga_compatible
vim.g["lightline#bufferline#enable_devicons"] = not vim.g.vga_compatible
vim.g["lightline#bufferline#clickable"]       = true

-- the minimum number of buffers & tabs needed to automatically show the tabline
vim.g["lightline#bufferline#min_buffer_count"] = 2
vim.g["lightline#bufferline#min_tab_count"]    = 2

-- Quick-Scope
-------------------------------------------------------------------------------
function vim.fn.qs_colors()
  for group, color in pairs({QuickScopePrimary=10, QuickScopeSecondary=13}) do
    vim.cmd(string.format("highlight %s guisp=%s gui=bold,underline ctermfg=%d cterm=bold,underline",
      group, vim.g["terminal_color_" .. color], color))
  end
end

vim.cmd([[
  augroup qs_colors
    autocmd!
    autocmd ColorScheme * lua vim.fn.qs_colors()
    autocmd VimEnter * lua vim.fn.qs_colors()
  augroup END
]])

vim.g.qs_highlight_on_keys = {"f", "F", "t", "T"}

-- Gitsigns
-------------------------------------------------------------------------------
local gitsigns = require("gitsigns")

gitsigns.setup{
  signs = {
    add = {hl = "GitSignsAdd", text = vga_fallback("▌", "+")},
    change = {hl = "GitSignsChange", text = vga_fallback("▌", "≈")},
    delete = {hl = "GitSignsDelete", text = vga_fallback("▖", "v")},
    topdelete = {hl = "GitSignsDelete", text = vga_fallback("▘", "^")},
    changedelete = {hl = "GitSignsChange", text = vga_fallback("▌", "±")},
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
local lsputil = require('lspconfig.util')

-- debounce 'didChange' notifications to the server
lsputil.default_config.flags = {debounce_text_changes = 150}
-- setup calls to specific language servers are located in ftplugins
function lsputil.on_setup(config)
  config.on_attach = lsputil.add_hook_before(config.on_attach, lsp_mappings)
end

-- LuaSnip
-------------------------------------------------------------------------------
require("luasnip.loaders.from_vscode").lazy_load()

-- we only define LuaSnip mappings for jumping around, expansion is handled by
-- insert mode completion (see help-page for 'ins-completion' and
-- 'completefunc' defined above).
for _, mode in pairs{"i", "s"} do
  keymap(mode, "<C-s><C-n>", "<cmd>lua require('luasnip').jump(1)<cr>", opts)
  keymap(mode, "<C-s><C-p>", "<cmd>lua require('luasnip').jump(-1)<cr>", opts)
  keymap(mode, "<C-s><C-j>", "luasnip#choice_active() ? '<Plug>luasnip-next-choice' : ''", {expr = true, unpack(opts)})
  keymap(mode, "<C-s><C-k>", "luasnip#choice_active() ? '<Plug>luasnip-prev-choice' : ''", {expr = true, unpack(opts)})
end

-- Telescope
-------------------------------------------------------------------------------
local telescope = setmetatable({}, {__index = function(_, k) return require("telescope.builtin")[k] end})

-- when a count N is given to a telescope mapping called through the following
-- function, the search is started in the Nth parent directory
function vim.fn.telescope_cwd(picker)
  telescope[picker]{cwd = vim.fn["repeat"]("../", vim.v.count or 0) .. "."}
end

keymap("n", "<leader>ff", "<cmd>lua vim.fn.telescope_cwd('find_files')<cr>", opts)
keymap("n", "<leader>lg", "<cmd>lua vim.fn.telescope_cwd('live_grep')<cr>", opts)
keymap("n", "<leader>ws", "<cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<cr>", opts)

-- }}}
-- vim: foldmethod=marker foldmarker=--\ {{{,--\ }}}
