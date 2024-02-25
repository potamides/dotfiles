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
vim.opt.completefunc = "v:lua.require'snipcomp'" -- custom snippet completion defined in lua/snipcomp.lua

-- show line numbers and highlight cursor line number
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

-- spell checking
vim.opt.spell = true
vim.opt.spelllang = {"en_us", "de_de", "cjk"}
vim.opt.spellfile = ("%s/spell/spf.%s.add"):format(vim.fn.stdpath("config"), vim.o.encoding)
vim.opt.thesaurusfunc = "v:lua.require'mythes'" -- support openoffice thesauri, see lua/mythes.lua
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
vim.g.is_bash	= true
vim.g.sh_no_error = true
vim.g.readline_has_bash = true
vim.g.tex_flavor = "latex"
vim.g.markdown_fenced_languages = {"python", "lua", "sh", "bash", "tex", "latex=tex"}

-- setup netrw and viewer for 'gx' mapping
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_winsize = -30
vim.g.netrw_special_syntax = 1
vim.g.netrw_browsex_viewer = "xdg-open"
vim.g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]]
vim.g.netrw_sort_options = "i"

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

-- open netrw file explorer and terminal
map("n", "<leader>fe", vim.cmd.Lexplore, opts)
map("n", "<leader>tm", vim.cmd.Terminal, opts)

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

-- small, custom wrapper around paq-nvim which installs paq automatically when
-- it is missing
autopaq.bootstrap{
  "savq/paq-nvim",
  "unblevable/quick-scope",
  "NvChad/nvim-colorizer.lua",
  "neovim/nvim-lspconfig",
  "mfussenegger/nvim-dap",
  "tpope/vim-fugitive",
  "potamides/pantran.nvim",
  "lewis6991/gitsigns.nvim",
  "nvim-lualine/lualine.nvim",
  "ibhagwan/fzf-lua",
  "robitx/gp.nvim",
  "ellisonleao/gruvbox.nvim",
  {"L3MON4D3/LuaSnip", build = "make install_jsregexp"},

  -- dependencies
  "rafamadriz/friendly-snippets", -- LuaSnip
  "nvim-tree/nvim-web-devicons",  -- lualine.nvim, fzf-lua
}

-- shorthand for updating packages with paq-nvim and showing (new) updates
cmd("Update", "silent PaqLogClean | PaqSync | autocmd User PaqDoneSync ++once ++nested PaqLogOpen", {})

local function lazy_require(module)
  return setmetatable({}, {
    __index = function(_, k) return require(module)[k] end,
    __newindex = function(_, k, v) require(module)[k] = v end
  })
end

-- gruvbox.nvim
-------------------------------------------------------------------------------
local gruvbox = require("gruvbox")

gruvbox.setup{
  italic = {strings = false},
  overrides = {
    -- diagnostic highlighting
    DiagnosticHint            = {link = "GruvboxPurple"},
    DiagnosticSignHint        = {link = "GruvboxPurpleSign"},
    DiagnosticUnderlineHint   = {link = "GruvboxPurpleUnderline"},
    DiagnosticFloatingHint    = {link = "GruvboxPurple"},
    DiagnosticVirtualTextHint = {link = "GruvboxPurple"},

    -- spelling highlighting
    SpellBad  = {link = "GruvboxBlueUnderline"},
    SpellCap  = {link = "GruvboxOrangeUnderline"},
    SpellRare = {link = "GruvboxGreenUnderline"},

    -- misc
    NormalFloat = {link = "Pmenu"},
  }
}

-- only enable this color scheme when supported by terminal
if not vim.g.vga_compatible then
  vim.cmd.colorscheme("gruvbox")
end

-- lualine.nvim
-------------------------------------------------------------------------------
local statusline, devicons = require("statusline"), require("nvim-web-devicons")

local function vga_fallback(regular, fallback)
  if vim.g.vga_compatible then return fallback else return regular end
end

devicons.setup{
  default = true,
  override = {default_icon = {icon = ""}}
}

statusline.setup{
  theme = vim.g.colors_name or "16color",
  icons_enabled = not vim.g.vga_compatible,
  separators = {
    component = { left = '│', right = '│'},
    section = { left = '▌', right = '▐'},
  },
  symbols = {
    edit    = vga_fallback("✎"),
    lock    = vga_fallback(""),
    git     = vga_fallback(""),
    line    = vga_fallback(""),
    error   = vga_fallback(""),
    warning = vga_fallback(""),
    info    = vga_fallback(""),
    hint    = vga_fallback(""),
    dap     = vga_fallback(""),
    spinner = vga_fallback{'⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'}
  }
}

-- quick-scope
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

-- gitsigns.nvim
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
    map('n', '<leader>bl', gitsigns.blame_line, bufopts)
  end
}

-- nvim-colorizer.lua
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

-- nvim-lspconfig
-------------------------------------------------------------------------------
local lsputil = require('lspconfig.util')

-- setup calls to specific language servers are located in ftplugins
lsputil.on_setup = lsputil.add_hook_before(lsputil.on_setup, function(config)
  config.on_attach = lsputil.add_hook_before(config.on_attach, lsp_mappings)
end)

-- nvim-dap
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
map({"n", "i", "s"}, "<C-s><C-n>", function() luasnip.jump(1) end, opts)
map({"n", "i", "s"}, "<C-s><C-p>", function() luasnip.jump(-1) end, opts)
map({"n", "i", "s"}, "<C-s><C-j>", function() try_change_choice(1) end, opts)
map({"n", "i", "s"}, "<C-s><C-k>", function() try_change_choice(-1) end, opts)

-- fzf-lua
-------------------------------------------------------------------------------
local fzf = require('fzf-lua')

fzf.setup{
  hls = {
    title = "PantranTitle",
    preview_title = "PantranTitle"
  },
  winopts = {
    border = "single",
    preview = {
      scrollbar = false,
      vertical = "up:45%",
      winopts = {number = false}
    },
    on_close = function()
      -- make lualine return to normal mode immediately
      vim.api.nvim_input("<Ignore>")
    end
  },
  diagnostics = {
    signs = {
      Error = {text = statusline.opts.symbols.error,   texthl = "DiagnosticError"},
      Warn  = {text = statusline.opts.symbols.warning, texthl = "DiagnosticWarn"},
      Info  = {text = statusline.opts.symbols.info,    texthl = "DiagnosticInfo"},
      Hint  = {text = statusline.opts.symbols.hint,    texthl = "DiagnosticHint"},
    }
  },
  lsp = {jump_to_single_result = true},
  fzf_opts = {["--layout"] = "default"},
  defaults = {file_icons = not vim.g.vga_compatible}
}

-- when a count N is given to a fzf mapping called through the following
-- function, the search is started in the Nth parent directory
local function fzf_cwd(picker, args)
  local target_dir = vim.loop.fs_realpath(("../"):rep(vim.v.count) .. ".")
  fzf[picker](vim.tbl_extend("error", args or {}, {cwd = target_dir}))
end

map("n", "<leader>ff", function() fzf_cwd('files') end, opts)
map("n", "<leader>rg", function() fzf_cwd('live_grep') end, opts)
map("n", "<leader>ds", fzf.lsp_document_symbols, opts)
map("n", "<leader>ws", fzf.lsp_live_workspace_symbols, opts)
map("n", "<leader>fz", fzf.builtin, opts)

-- if fzf binary is available patch ui.select and some previous mappings
if vim.fn.executable("fzf") == 1 then
  fzf.register_ui_select()
  map("n", "<leader>ll", fzf.diagnostics_document, opts)
  map("n", "<leader>bs", fzf.dap_breakpoints, opts)

  lsp_mappings = lsputil.add_hook_after(lsp_mappings, function(_, buf)
    local bufopts = {buffer = buf, unpack(opts)}
    map("n", "gd",         fzf.lsp_definitions, bufopts)
    map("n", "gD",         fzf.lsp_declarations, bufopts)
    map("n", "<leader>gi", fzf.lsp_implementations, bufopts)
    map("n", "<leader>gt", fzf.lsp_typedefs, bufopts)
    map("n", "<leader>ca", fzf.lsp_code_actions, bufopts)
    map("n", "<leader>rf", fzf.lsp_references, bufopts)
  end)
end

-- pantran.nvim
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

map({"n", "v"}, "<leader>tr", pantran.motion_translate, {expr = true, unpack(opts)})
map("n", "<leader>trr", function() return pantran.motion_translate() .. "_" end, {expr = true, unpack(opts)})

-- gp.nvim
-------------------------------------------------------------------------------
local gp = require("gp")

gp.setup{
  chat_user_prefix = "## User",
  chat_assistant_prefix = "## Assistant",
  command_prompt_prefix = "Prompt: ",
  chat_confirm_delete = false,
  chat_model = {model = "gpt-4", temperature = 0.7, top_p = 1},
  command_model = {model = "gpt-4", temperature = 0.7, top_p = 1},
  chat_shortcut_respond = {modes = {"n", "v"}, shortcut = "<cr>"},
  chat_shortcut_delete = {modes = {"n", "v"}, shortcut = "<leader>gd"},
  chat_shortcut_new = {modes = {"n", "v"}, shortcut = "<leader>gn"},
}

for mode, key in pairs{n = "<cmd>", v = ":"} do
  map(mode, "<leader>gn", key .. "GpChatNew<cr>", opts)
  map(mode, "<leader>go", key .. "GpChatToggle<cr>", opts)
  map(mode, "<leader>gO", key .. "GpPopup<cr>", opts)
  map(mode, "<leader>g/", key .. "GpChatFinder<cr>", opts)

  map(mode, "<leader>gs", key .. "GpRewrite<cr>", opts)
  map(mode, "<leader>gp", key .. "GpAppend<cr>", opts)
  map(mode, "<leader>gP", key .. "GpPrepend<cr>", opts)

  map(mode, "<leader>gx", "<cmd>GpStop<cr>", opts)
end

 -- see :h :map-operator
local function motion_cmd(command)
  return function()
    vim.opt.operatorfunc = ([[{ -> execute("'[,']%s")}]]):format(command)
    return 'g@'
  end
end

map({"n", "v"}, "<leader>gI", motion_cmd("GpImplement"), {expr = true, unpack(opts)})
map("n", "<leader>gII", function() return motion_cmd("GpImplement") .. "_" end, {expr = true, unpack(opts)})

-- hack to modify style and behavior of popup window
local create_popup = gp._H.create_popup
function gp._H.create_popup(optbuf, title, ...)
  local buf, win, close, resize = create_popup(optbuf, (" %s "):format(title), ...)
  map("n", "<esc>", "<cmd>close<cr>", {buffer = buf, unpack(opts)})
  vim.cmd.call{("setbufvar(%d, '&buflisted', 0)"):format(buf), mods={noautocmd=true}}
  vim.api.nvim_win_set_option(win, "winhighlight",
    "Normal:PantranNormal,FloatTitle:PantranTitle,FloatBorder:PantranBorder")
  return buf, win, close, resize
end

-- }}}
-- vim: foldmethod=marker foldmarker=--\ {{{,--\ }}}
