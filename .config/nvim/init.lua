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
vim.opt.completefunc = "v:lua.vim.luasnip.completefunc" -- custom snippet completion defined in plugin/snipcomp.lua

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
vim.g.markdown_fenced_languages = {"bash=sh", "python", "lua"}

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

-- jump to last position when opening a file
local open = au("user_open")
function open.BufReadPost()
  local last_cursor_pos, last_line = vim.fn.line([['"]]), vim.fn.line("$")
  if last_cursor_pos > 1 and last_cursor_pos <= last_line then
    vim.fn.cursor(last_cursor_pos, 1)
  end
end

-- briefly highlight a selection on yank
local yank = au("user_yank")
function yank.TextYankPost()
  vim.highlight.on_yank()
end

-- automatically toggle between relative and absolute line numbers depending on mode
local number = au{"user_number",
  Relative={"BufEnter", "FocusGained", "InsertLeave", "TermLeave", "WinEnter"},
  Absolute={"BufLeave", "FocusLost", "InsertEnter", "TermEnter", "WinLeave"}
}

function number.Relative()
  if vim.opt_local.number:get() and vim.fn.mode() ~= "i" then
    vim.opt_local.relativenumber = true
  end
end

function number.Absolute()
  if vim.opt_local.number:get() then
    vim.opt_local.relativenumber = false
  end
end

-- close preview window when completion is finished
local preview = au("user_preview")
function preview.CompleteDone()
  if vim.fn.pumvisible() == 0 and vim.fn.getcmdwintype() == "" then
    vim.cmd.pclose()
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

-- open (new) terminal at bottom of the current tab (using default instance)
cmd("Terminal", function(tbl)
    require("term"):open{cmd = #tbl.fargs > 0 and tbl.fargs or nil}
  end, {nargs = "*", complete = "shellcmd"}
)

cmd("Cd", "cd %:p:h", {})            -- set cwd to directory of current file
cmd("Run", '!"%:p"', {})             -- Execute current file
cmd("Bd", "bp|bd #", {})             -- delete buffer without closing split
cmd("Config", "edit $MYVIMRC", {})   -- open config file with :Config
cmd("Reload", "source $MYVIMRC", {}) -- reload config file with :Reload

-- Mappings
-------------------------------------------------------------------------------
local map, opts = vim.keymap.set, {noremap = true, silent = true}

-- navigate buffers like tabs (gt & gT)
map("n", "gb", function() vim.cmd.bnext{count = vim.v.count1} end, opts)
map("n", "gB", function() vim.cmd.bprev{count = vim.v.count1} end, opts)

-- diagnostics mappings
map("n", "<leader>ll", vim.diagnostic.setloclist, opts)
map("n", "<leader>ld", vim.diagnostic.open_float, opts)
map("n", "[d",         vim.diagnostic.goto_prev, opts)
map("n", "]d",         vim.diagnostic.goto_next, opts)

-- language server mappings
local function lsp_mappings(_, buf)
  local bufopts = {buffer = buf, unpack(opts)}
  map("n", "gd",         vim.lsp.buf.definition, bufopts)
  map("n", "gD",         vim.lsp.buf.declaration, bufopts)
  map("n", "<leader>gi", vim.lsp.buf.implementation, bufopts)
  map("n", "<leader>gt", vim.lsp.buf.type_definition, bufopts)
  map("n", "K",          vim.lsp.buf.hover, bufopts)
  map("n", "<C-k>",      vim.lsp.buf.signature_help, bufopts)
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
  map("n", "<leader>wl", function() vim.print(vim.lsp.buf.list_workspace_folders()) end, bufopts)
  map("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
  map("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
  map("n", "<leader>rf", vim.lsp.buf.references, bufopts)
  map("n", "<leader>fm", function() vim.lsp.buf.format{async = true} end, bufopts)
  map("v", "<leader>fm", ":lua vim.lsp.formatexpr()<cr>", bufopts) -- return to normal mode
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
local autopaq = require("autopaq")

-- small, custom wrapper around paq-nvim which installs paq
-- automatically when it is missing
autopaq.bootstrap{
  "savq/paq-nvim",
  "unblevable/quick-scope",
  "NvChad/nvim-colorizer.lua",
  "neovim/nvim-lspconfig",
  "mfussenegger/nvim-dap",
  "tpope/vim-fugitive",
  "potamides/pantran.nvim",
  "lewis6991/gitsigns.nvim",
  "L3MON4D3/LuaSnip",
  "itchyny/lightline.vim",
  "nvim-telescope/telescope.nvim",
  "gruvbox-community/gruvbox",

  -- dependencies
  "rafamadriz/friendly-snippets",                             -- LuaSnip
  "mgee/lightline-bufferline",                                -- lightline.nvim
  "kyazdani42/nvim-web-devicons",                             -- lightline.nvim
  "nvim-lua/plenary.nvim",                                    -- gitsigns.nvim, telescope.nvim
  {"nvim-telescope/telescope-fzf-native.nvim", run = "make"}, -- telescope.nvim
}

-- shorthand for updating packages with paq-nvim and showing (new) updates
cmd("Update", "silent PaqLogClean | PaqSync | autocmd User PaqDoneSync ++once ++nested PaqLogOpen", {})

local function lazy_require(module)
  return setmetatable({}, {
    __index = function(_, k) return require(module)[k] end,
    __newindex = function(_, k, v) require(module)[k] = v end
  })
end

-- Gruvbox
-------------------------------------------------------------------------------
vim.g.gruvbox_contrast_dark = "medium"
vim.g.gruvbox_italic = true
vim.g.gruvbox_invert_selection = false

-- only enable this color scheme when supported by terminal
if not vim.g.vga_compatible then
  vim.cmd.colorscheme("groovebox") -- customized gruvbox in colors/groovebox.lua
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
vim.g["lightline#bufferline#unnamed"]         = "[No Name]"
vim.g["lightline#bufferline#clickable"]       = true

-- the minimum number of buffers & tabs needed to automatically show the tabline
vim.g["lightline#bufferline#min_buffer_count"] = 2
vim.g["lightline#bufferline#min_tab_count"]    = 2

-- set default icon to same as vim-devicons
devicons.set_default_icon("")

-- Quick-Scope
-------------------------------------------------------------------------------
local quickscope = au{"user_quickscope", LoadPost={"ColorScheme", "VimEnter"}}
vim.g.qs_highlight_on_keys = {"f", "F", "t", "T"}

function quickscope.LoadPost()
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
    untracked    = {hl = 'GitSignsAdd'   , text = vga_fallback("▌", "+")},
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
colorizer.setup{
  filetypes = { "*" },
  user_default_options = {
    names = false,
    mode = 'virtualtext'
  }
}


-- Lsp-config
-------------------------------------------------------------------------------
local lsputil = require('lspconfig.util')

-- setup calls to specific language servers are located in ftplugins
function lsputil.on_setup(config)
  config.on_attach = lsputil.add_hook_before(config.on_attach, lsp_mappings)
end

-- Nvim-DAP
-------------------------------------------------------------------------------
local dap = require("dap")
local dapterm = require("term").instance()

vim.fn.sign_define{
  {name = "DapBreakpoint", texthl = "debugBreakpoint"},
  {name = "DapBreakpointCondition", texthl = "debugBreakpoint"},
  {name = "DapLogPoint", texthl = "debugBreakpoint"},
  {name = "DapBreakpointRejected", texthl = "debugBreakpoint"},
  {name = "DapStopped", texthl = "debugBreakpoint"}
}

-- integrate our own terminal wrapper with dap
function dap.defaults.fallback.terminal_win_cmd()
  return dapterm:open{cmd = false, nofocus = true}
end

local function repl_open()
  local _, win = dap.repl.open(nil, "lua require('term'):open{noinsert = true}")
  vim.api.nvim_set_current_win(win)
  vim.cmd.startinsert()
end

local function try_call(func, ...)
  if dap.session() then func(...) else vim.notify('No active session') end
end

map("n", "<leader>cc", dap.continue, opts)
map("n", "<leader>ss", dap.step_over, opts)
map("n", "<leader>si", dap.step_into, opts)
map("n", "<leader>so", dap.step_out, opts)
map("n", "<leader>rc", dap.run_to_cursor, opts)
map("n", "<leader>br", dap.toggle_breakpoint, opts)
map("n", "<leader>bc", function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, opts)
map("n", "<leader>bl", function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, opts)
map("n", "<leader>bd", dap.clear_breakpoints, opts)
map("n", "<leader>bs", function() dap.list_breakpoints() vim.cmd.copen() end, opts)
map("n", "<leader>ro", function() try_call(repl_open) end, opts)
map("n", "<leader>to", function() try_call(function() dapterm:open{nofocus = true} end) end, opts)
map("n", "<leader>rl", dap.run_last, opts)
map("n", "<leader>te", dap.terminate, opts)

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

telescope.setup{
  defaults = {
    borderchars = {"─", "│", "─", "│", "┌", "┐", "┘", "└"}
  }
}

vim.api.nvim_set_hl(0, "TelescopeTitle", {link = "PantranTitle"})
telescope.load_extension('fzf')

-- when a count N is given to a telescope mapping called through the following
-- function, the search is started in the Nth parent directory
local function telescope_cwd(picker, args)
  builtin[picker](vim.tbl_extend("error", args or {}, {cwd = ("../"):rep(vim.v.count) .. "."}))
end

map("n", "<leader>ff", function() telescope_cwd('find_files', {hidden = true}) end, opts)
map("n", "<leader>lg", function() telescope_cwd('live_grep') end, opts)
map("n", "<leader>ds", builtin.lsp_document_symbols, opts)
map("n", "<leader>ws", builtin.lsp_dynamic_workspace_symbols, opts)

-- Pantran
-------------------------------------------------------------------------------
local pantran = require("pantran")

pantran.setup{
  default_engine = vim.env.DEEPL_AUTH_KEY and "deepl" or nil,
  controls = {
    mappings = {
      edit = {
        n = {
          ["j"] = "gj",
          ["k"] = "gk"
        }
      }
    }
  }
}

map("n", "<leader>tr", pantran.motion_translate, {expr = true, unpack(opts)})
map("n", "<leader>trr", function() return pantran.motion_translate() .. "_" end, {expr = true, unpack(opts)})
map("x", "<leader>tr", pantran.motion_translate, {expr = true, unpack(opts)})

-- }}}
-- vim: foldmethod=marker foldmarker=--\ {{{,--\ }}}
