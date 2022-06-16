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

-- tabs are two spaces
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- line break configuration
vim.opt.textwidth = 79
vim.opt.colorcolumn = {80, 120}
vim.opt.breakindent = true
vim.opt.linebreak = true

-- set list chars for horizontal scrolling
vim.opt.listchars:append{tab = "» ", precedes = "<", extends = ">"}
vim.opt.list = true

-- built-in completion & tag search
vim.opt.completeopt:append{"menuone", "noinsert"}
vim.opt.complete:remove{"t"}
vim.opt.omnifunc = "v:lua.vim.lsp.omnifunc"             -- neovim internal lsp completion
vim.opt.completefunc = "v:lua.vim.luasnip.completefunc" -- custom snippet completion defined in plugin/snipcomp.lua
vim.opt.tagfunc = "v:lua.vim.lsp.tagfunc"               -- interface to normal mode commands like CTRL-]

-- show line numbers and highlight cursor line number
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

-- spell checking
vim.opt.spell = true
vim.opt.spelllang = {"en_us", "de_de", "cjk"}
vim.opt.spellfile = vim.fn.expand("~/.local/share/nvim/site/spell/spf.%s.add"):format(vim.o.encoding)
vim.opt.thesaurusfunc = "v:lua.vim.openoffice.thesaurusfunc" -- support openoffice thesauri, see plugin/thesaurus.lua
vim.opt.thesaurus = {
  -- archlinux packages extra/mythes-{en,de,..}
  "/usr/share/mythes/th_en_US_v2.dat",
  "/usr/share/mythes/th_de_DE_v2.dat"
}

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
vim.opt.title = true           -- set terminal window title to something descriptive
vim.opt.foldlevel = 99         -- do not automatically close folds when editing a file
vim.opt.inccommand = "nosplit" -- show incremental changes of commands such as search & replace
vim.opt.virtualedit = "block"  -- virtual editing in visual block mode
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
vim.g.netrw_browse_split = 4
vim.g.netrw_winsize = 25
vim.g.netrw_browsex_viewer = "xdg-open"

vim.g.python3_host_prog = "/usr/bin/python3"   -- use system python (useful when working with virualenvs)
vim.g.vga_compatible = vim.env.TERM == "linux" -- VGA textmode fallback (with CP437 character set) for legacy terminals

-- Automatic commands
-------------------------------------------------------------------------------
local au = require("au") -- small wrapper around lua autocmd api

-- start insert mode when opening a terminal
local open = au("user_open")
function open.TermOpen()
  vim.cmd("startinsert")
end

-- jump to last position when opening a file
function open.BufReadPost()
  local last_cursor_pos, last_line = vim.fn.line([['"]]), vim.fn.line("$")
  if last_cursor_pos > 1 and last_cursor_pos <= last_line then
    vim.fn.cursor(last_cursor_pos, 1)
  end
end

-- quickfix for https://github.com/neovim/neovim/issues/11330
function open.VimEnter()
  local pid, WINCH = vim.fn.getpid(), vim.loop.constants.SIGWINCH
  vim.defer_fn(function() vim.loop.kill(pid, WINCH) end, 20)
end

-- briefly highlight a selection on yank
local yank = au("user_yank")
function yank.TextYankPost()
  vim.highlight.on_yank()
end

-- automatically toggle between relative and absolute line numbers depending on mode
local number = au("user_number")
local relative = number{"BufEnter", "FocusGained", "InsertLeave", "TermLeave", "WinEnter"}
local absolute = number{"BufLeave", "FocusLost", "InsertEnter", "TermEnter", "WinLeave"}

function relative.handler()
  if vim.opt_local.number:get() and vim.fn.mode() ~= "i" then
    vim.opt_local.relativenumber = true
  end
end

function absolute.handler()
  if vim.opt_local.number:get() then
    vim.opt_local.relativenumber = false
  end
end

-- close preview window when completion is finished
local preview = au("user_preview")
function preview.CompleteDone()
  if vim.fn.pumvisible() == 0 then
    vim.cmd[[pclose]]
  end
end

-- restore view of current window when switching buffers
local view = au("user_view")
function view.BufWinLeave()
  vim.b.view = vim.fn.winsaveview()
end

function view.BufWinEnter()
  if vim.b.view then
    vim.fn.winrestview(vim.b.view)
    vim.b.view = nil
  end
end

-- Commands
-------------------------------------------------------------------------------
local cmd = vim.api.nvim_create_user_command

-- open (new) terminal at the bottom of the current tab
cmd("Terminal", function(tbl)
    require("term").open(#tbl.args > 0 and tbl.args or nil)
  end, {nargs = "?"}
)

cmd("Cd", "cd %:p:h", {})            -- set cwd to directory of current file
cmd("Run", '!"%:p"', {})             -- Execute current file
cmd("Config", "edit $MYVIMRC", {})   -- open config file with :Config
cmd("Reload", "source $MYVIMRC", {}) -- reload config file with :Reload

-- Mappings
-------------------------------------------------------------------------------
local map, opts = vim.keymap.set, {noremap = true, silent = true}

-- navigate buffers like tabs (gt & gT)
map("n", "gb", function() vim.cmd("bnext" .. vim.v.count1) end, opts)
map("n", "gB", function() vim.cmd("bprev" .. vim.v.count1) end, opts)

-- diagnostics mappings
map("n", "<leader>ll", vim.diagnostic.setloclist, opts)
map("n", "<leader>ld", vim.diagnostic.open_float, opts)
map("n", "[d",         vim.diagnostic.goto_prev, opts)
map("n", "]d",         vim.diagnostic.goto_next, opts)

-- language server mappings
local function lsp_mappings(client, buf)
  local bufopts = {buffer = buf, unpack(opts)}
  map("n", "gd",         vim.lsp.buf.definition, bufopts)
  map("n", "gD",         vim.lsp.buf.declaration, bufopts)
  map("n", "<leader>gi", vim.lsp.buf.implementation, bufopts)
  map("n", "<leader>gt", vim.lsp.buf.type_definition, bufopts)
  map("n", "K",          vim.lsp.buf.hover, bufopts)
  map("n", "<C-k>",      vim.lsp.buf.signature_help, bufopts)
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
  map("n", "<leader>wl", function() vim.pretty_print(vim.lsp.buf.list_workspace_folders()) end, bufopts)
  map("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
  map("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
  map("n", "<leader>rf", vim.lsp.buf.references, bufopts)
  map("n", "<leader>fm", vim.lsp.buf.formatting, bufopts)
  map("v", "<leader>fm", ":lua vim.lsp.buf.range_formatting()<cr>", bufopts) -- return to normal mode

  if client.server_capabilities.documentRangeFormattingProvider then
    -- Use LSP as the handler for 'gq' mapping
    vim.api.nvim_buf_set_option(buf, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')
  end
end

-- Diagnostics
-------------------------------------------------------------------------------
local prefix = "DiagnosticSign"

-- when not on the console set some nice signs
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
        "kyazdani42/nvim-web-devicons"
      }
    },
    {
      "nvim-telescope/telescope.nvim",
      requires = {
        "nvim-lua/plenary.nvim",
        "kyazdani42/nvim-web-devicons",
        {
          "nvim-telescope/telescope-fzf-native.nvim",
          run = "make"
        }
      }
    },
    {
      "gruvbox-community/gruvbox",
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

local function lazy_require(module)
  return setmetatable({}, {__index = function(_, k) return require(module)[k] end})
end

-- Gruvbox
-------------------------------------------------------------------------------
vim.g.gruvbox_contrast_dark = "medium"
vim.g.gruvbox_italic = true
vim.g.gruvbox_invert_selection = false

-- only enable this color scheme when supported by terminal
if not vim.g.vga_compatible then
  vim.cmd("colorscheme gruvbox")
end

-- Lightline
-------------------------------------------------------------------------------
local components = require("components")
local devicons = require("nvim-web-devicons")

local function vga_fallback(regular, fallback)
  return vim.g.vga_compatible and fallback or regular
end

local function get_icon()
  return devicons.get_icon(vim.fn.expand("%:t"), nil, {default = true})
end

-- signs for custom lightline components defined in lua/components.lua
components.setup{
  signs = {
    edit     = vga_fallback("✎", "+"),
    lock     = vga_fallback("", "-"),
    git      = vga_fallback("", "↨"),
    error    = vga_fallback("", "‼"),
    warning  = vga_fallback("", "!"),
    filetype = vga_fallback(get_icon, "≡"),
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

-- set default icon to same as vim-devicons
devicons.set_default_icon("")

-- Quick-Scope
-------------------------------------------------------------------------------
local quickscope = au("user_quickscope"){"ColorScheme", "VimEnter"}
vim.g.qs_highlight_on_keys = {"f", "F", "t", "T"}

function quickscope.handler()
  for group, color in pairs({QuickScopePrimary=10, QuickScopeSecondary=13}) do
    vim.api.nvim_set_hl(0, group, {
      sp = vim.g["terminal_color_" .. color],
      ctermfg = color,
      bold = true,
      underline = true
    })
  end
end

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
  },
  preview_config = {
    border = "none"
  },
  on_attach = function(buf)
    local bufopts = {buffer = buf, unpack(opts)}

    local function jump(direction)
      if vim.wo.diff then
        return ']c'
      end
      vim.schedule(direction)
      return '<Ignore>'
    end

    -- Navigation
    map("n", "]c", function() return jump(gitsigns.next_hunk) end, {expr = true, unpack(bufopts)})
    map("n", "[c", function() return jump(gitsigns.prev_hunk) end, {expr = true, unpack(bufopts)})

    -- Actions
    map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>', bufopts)
    map('n', '<leader>hp', gitsigns.preview_hunk, bufopts)

    -- highlight deleted lines in hunk previews in gitsigns.nvim
    vim.api.nvim_set_hl(0, "GitSignsDeleteLn", {link = "GitSignsDeleteVirtLn"})
  end
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

-- setup calls to specific language servers are located in ftplugins
function lsputil.on_setup(config)
  config.on_attach = lsputil.add_hook_before(config.on_attach, lsp_mappings)
end

-- LuaSnip
-------------------------------------------------------------------------------
local luasnip = lazy_require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

local function try_change_choice(direction)
  if luasnip.choice_active() then
    luasnip.change_choice(direction)
  end
end

-- we only define LuaSnip mappings for jumping around, expansion is handled by
-- insert mode completion (see help-page for 'ins-completion' and
-- 'completefunc' defined above).
map({"i", "s"}, "<C-s><C-n>", function() luasnip.jump(1) end, opts)
map({"i", "s"}, "<C-s><C-p>", function() luasnip.jump(-1) end, opts)
map({"i", "s"}, "<C-s><C-j>", function() try_change_choice(1) end, opts)
map({"i", "s"}, "<C-s><C-k>", function() try_change_choice(-1) end, opts)

-- Telescope
-------------------------------------------------------------------------------
local telescope = require("telescope")
local builtin = lazy_require("telescope.builtin")

telescope.load_extension('fzf')

-- when a count N is given to a telescope mapping called through the following
-- function, the search is started in the Nth parent directory
local function telescope_cwd(picker, args)
  builtin[picker](vim.tbl_extend("error", args or {}, {cwd = ("../"):rep(vim.v.count) .. "."}))
end

map("n", "<leader>ff", function() telescope_cwd('find_files', {hidden = true}) end, opts)
map("n", "<leader>lg", function() telescope_cwd('live_grep') end, opts)
map("n", "<leader>ws", function() builtin.lsp_dynamic_workspace_symbols() end, opts)

-- }}}
-- vim: foldmethod=marker foldmarker=--\ {{{,--\ }}}
