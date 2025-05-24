--[[
  Main Neovim configuration. Aims to be mostly language agnostic. Code which is
  language specific and buffer-local was moved to corresponding ftplugins in
  the directory "ftplugin" instead. Also, larger chunks of coherent code were
  refactored into libraries in "lua" or plugins in "plugin" to not clutter the
  main configuration file.
--]]

-------------------------------------------------------------------------------
-- {{{ General Configuration
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
vim.opt.smoothscroll = true
vim.opt.showbreak = "> "

-- set list chars for horizontal scrolling
vim.opt.listchars:append{tab = "» ", precedes = "<", extends = ">"}
vim.opt.list = true

-- built-in completion & tag search
vim.opt.completeopt:append{"fuzzy", "menuone", "noinsert", "popup"}
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

vim.opt.undofile = true         -- persistent undo history
vim.opt.showmode = false        -- do not show mode message on last line
vim.opt.hidden = true           -- switch buffers without having to save changes
vim.opt.joinspaces = false      -- insert one space when joining two sentences
vim.opt.confirm = true          -- raise dialog asking to save changes when commands like ':q' fail
vim.opt.title = true            -- set terminal window title to something descriptive
vim.opt.foldlevel = 99          -- do not automatically close folds when editing a file
vim.o.foldtext = ''             -- enable syntax highlighting for folds
vim.opt.inccommand = "nosplit"  -- show incremental changes of commands such as search & replace
vim.opt.virtualedit = "block"   -- virtual editing in visual block mode
vim.opt.shortmess:append("Ic")  -- disable intro and ins-completion messages

if vim.env.TERM == "linux" then
  vim.opt.title = false
end

-- Variables
-------------------------------------------------------------------------------

-- define leaders for use in keybindings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- syntax/indent related global variables
vim.g.is_bash = true
vim.g.sh_no_error = true
vim.g.readline_has_bash = true
vim.g.tex_stylish = true
vim.g.tex_flavor = "latex"
vim.g.markdown_fenced_languages = {"python", "lua", "sh", "bash", "tex", "latex=tex"}
vim.g.python_indent = {open_paren = "shiftwidth()", continue = "shiftwidth()", closed_paren_align_last_line = false}

-- setup netrw and viewer for 'gx' mapping
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_winsize = -30
vim.g.netrw_special_syntax = 1
vim.g.netrw_browsex_viewer = "xdg-open"
vim.g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]]
vim.g.netrw_sort_options = "i"

vim.g.clipboard = "osc52"                    -- use OSC 52 for copying and pasting
vim.g.python3_host_prog = "/usr/bin/python3" -- use system python (useful when working with virualenvs)
vim.g.vga_compatible = false                 -- VGA textmode fallback (with CP437 character set) for legacy terminals

if vim.env.TERM == "linux" then
  vim.g.vga_compatible = true
  vim.g.clipboard = nil
end

-- Autocmds
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

-- disable spell checking inside terminal buffers
function open.TermOpen()
  vim.opt_local.spelllang = ""
end

-- briefly highlight a selection on yank
local yank = au("user_yank")
function yank.TextYankPost()
  vim.highlight.on_yank()
end

-- automatically toggle between relative and absolute line numbers depending on mode
local number = au{"user_number",
  Relative = {"BufEnter", "FocusGained", "InsertLeave", "TermLeave", "WinEnter"},
  Absolute = {"BufLeave", "FocusLost", "InsertEnter", "TermEnter", "WinLeave"}
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

-- enable syntax highlighting for bash's edit-and-execute-command
vim.filetype.add{pattern = {["bash%-fc%.%w+"] = "sh"}}

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

-- mappings for some commands
local map, opts = vim.keymap.set, {noremap = true, silent = true}

map("n", "<leader>tm", vim.cmd.Terminal, opts)
map("n", "<leader>fe", vim.cmd.Lexplore, opts)
map("n", "<leader>il", function() vim.cmd.set("cursorcolumn!") end, opts)

-- find wrapper command for nvim (see bin/nvim)
vim.env.PATH = ("%s/bin:%s"):format(vim.fn.stdpath("config"), vim.env.PATH)

-- Diagnostics
-------------------------------------------------------------------------------

-- diagnostics mappings
map("n", "<leader>ll", vim.diagnostic.setloclist, opts)
map("n", "<leader>ld", vim.diagnostic.open_float, opts)

-- when not on the console set some nice signs
if not vim.g.vga_compatible then
  vim.diagnostic.config{
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "▌",
        [vim.diagnostic.severity.WARN]  = "▌",
        [vim.diagnostic.severity.HINT]  = "▌",
        [vim.diagnostic.severity.INFO]  = "▌",
      },
      texthl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        [vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
        [vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
        [vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
      }
    }
  }
end

vim.diagnostic.config{
  jump = {float = true},
  virtual_text = vim.g.vga_compatible and true or {prefix = "▪"}
}

-- LSP
-------------------------------------------------------------------------------
local lsp = au("user_lsp")

function lsp.LspAttach(args)
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  local bufopts = {buffer = args.buf, unpack(opts)}

  --additional mappings
  map("n", "grd",             vim.lsp.buf.definition, bufopts)
  map("n", "<localleader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
  map("n", "<localleader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
  map("n", "<localleader>wl", function() vim.print(vim.lsp.buf.list_workspace_folders()) end, bufopts)

  -- map inlay hints if supported
  if client:supports_method("textDocument/inlayHint") then
    local hint, bufnr = vim.lsp.inlay_hint, {bufnr = args.buf}
    map("n", "grh", function() hint.enable(not hint.is_enabled(bufnr), bufnr) end, bufopts)
    hint.enable(true, bufnr)
  end

  -- enable completion if supported
  if client:supports_method("textDocument/completion") then
    vim.lsp.completion.enable(true, client.id, args.buf, {autotrigger = true})
  end

  -- enable LSP folding if supported
  if client:supports_method('textDocument/foldingRange') then
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"
  end
end

-- enable LSP servers (check /lsp)
vim.lsp.enable({
  vim.fn.executable('basedpyright') == 1 and "basedpyright" or "pyright",
  "bashls",
  "lua_ls",
  "texlab"
})

-- Treesitter
-------------------------------------------------------------------------------
local treesitter = au("user_treesitter")

-- enable Treesitter folding and highlighting if parser available
function treesitter.FileType(args)
  local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
  if lang and vim.treesitter.language.add(lang) then
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.treesitter.start(args.buf, lang)
  end
end

-- }}}
-------------------------------------------------------------------------------
-- {{{ User-installed plugin Configuration
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
  {"nvim-treesitter/nvim-treesitter", build = ":TSInstallSync all | TSUpdate"},
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
  terminal_colors = false,
  overrides = {
    -- diagnostic highlighting
    DiagnosticHint            = {link = "GruvboxPurple"},
    DiagnosticSignHint        = {link = "GruvboxPurpleSign"},
    DiagnosticUnderlineHint   = {link = "GruvboxPurpleUnderline"},
    DiagnosticFloatingHint    = {link = "GruvboxPurple"},
    DiagnosticVirtualTextHint = {link = "GruvboxPurple"},
    -- spelling highlighting
    SpellBad                  = {link = "GruvboxBlueUnderline"},
    SpellCap                  = {link = "GruvboxOrangeUnderline"},
    SpellRare                 = {link = "GruvboxGreenUnderline"},
    -- git signs
    GitSignsAdd               = {link = "GruvboxGreenSign"},
    GitSignsChange            = {link = "GruvboxAquaSign"},
    GitSignsDelete            = {link = "GruvboxRedSign"},
    GitSignsTopdelete         = {link = "GruvboxRedSign"},
    GitSignsChangedelete      = {link = "GruvboxAquaSign"},
    GitSignsUntracked         = {link = "GruvboxGreenSign"},
    -- misc
    NormalFloat               = {link = "Pmenu"},
    Todo                      = {link = "MiniHipatternsTodo"},
  }
}

-- only enable this color scheme when supported by terminal
if not vim.g.vga_compatible then
  vim.cmd.colorscheme("gruvbox")
end

-- lualine.nvim
-------------------------------------------------------------------------------
local statusline, devicons = require("statusline"), require("nvim-web-devicons")

local function vga(regular, fallback)
  if vim.g.vga_compatible then return fallback else return regular end
end

devicons.setup{
  default = true,
  override = {default_icon = {icon = ""}}
}

statusline.setup{
  theme = vim.g.colors_name or "ansi",
  icons_enabled = not vim.g.vga_compatible,
  separators = {
    component = {left = "│", right = "│"},
    section = {left = "▌", right = "▐"},
  },
  symbols = {
    edit    = vga("󰐕"),
    lock    = vga(""),
    git     = vga(""),
    line    = vga(""),
    error   = vga(""),
    warning = vga(""),
    info    = vga(""),
    hint    = vga(""),
    dap     = vga(""),
    more    = vga("…"),
    spinner = vga{"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"}
  }
}

-- quick-scope
-------------------------------------------------------------------------------
local quickscope = au{"user_quickscope", LoadPost = {"ColorScheme", "VimEnter"}}
vim.g.qs_highlight_on_keys = {"f", "F", "t", "T"}

function quickscope.LoadPost()
  for group, severity in pairs{Primary = "Ok", Secondary = "Hint"} do
    local hl = vim.api.nvim_get_hl(0, {name = "Diagnostic" .. severity, link = false})
    vim.api.nvim_set_hl(0, "QuickScope" .. group, {
      sp = hl.fg,
      ctermfg = hl.ctermfg,
      bold = true,
      underline = vga(true)
    })
  end
end

-- gitsigns.nvim
-------------------------------------------------------------------------------
local gitsigns = require("gitsigns")

gitsigns.setup{
  signs_staged_enable = false,
  signs = {
    add          = {text = vga("▌")},
    change       = {text = vga("▌")},
    delete       = {text = vga("▖")},
    topdelete    = {text = vga("▘")},
    changedelete = {text = vga("▌")},
    untracked    = {text = vga("▌")},
  },
  preview_config = {
    border = "none"
  },
  on_attach = function(buf)
    local bufopts = {buffer = buf, unpack(opts)}

    local function jump(direction)
      if vim.wo.diff then
        return "]c"
      end
      vim.schedule(direction)
      return "<Ignore>"
    end

    -- Navigation
    map("n", "]c", function() return jump(gitsigns.next_hunk) end, {expr = true, unpack(bufopts)})
    map("n", "[c", function() return jump(gitsigns.prev_hunk) end, {expr = true, unpack(bufopts)})

    -- Actions
    map({"n", "v"}, "<leader>hr", ":Gitsigns reset_hunk<CR>", bufopts)
    map("n", "<leader>hp", gitsigns.preview_hunk, bufopts)
    map("n", "<leader>bl", gitsigns.blame_line, bufopts)
  end
}

-- nvim-colorizer.lua
------------------------------------------------------------------------------
local colorizer = require("colorizer")

-- colorize color specifications like '#aabbcc' in virtualtext
colorizer.setup{
  filetypes = {"*"},
  user_default_options = {
    names = false,
    mode = "virtualtext"
  }
}

-- nvim-dap
-------------------------------------------------------------------------------
local dap = require("dap")
local dapwidgets = require("dap.ui.widgets")
local dapterm = require("term").instance()

vim.fn.sign_define{
  {name = "DapBreakpoint", texthl = "debugBreakpoint", text = vga("")},
  {name = "DapBreakpointCondition", texthl = "debugBreakpoint", text = vga("")},
  {name = "DapLogPoint", texthl = "debugBreakpoint", text = vga("")},
  {name = "DapBreakpointRejected", texthl = "debugBreakpoint", text = vga("")},
  {name = "DapStopped", texthl = "debugBreakpoint", text = vga("󰁕")}
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

local sidebars = {
  dapwidgets.sidebar(dapwidgets.scopes, nil, "Lexplore!"),
  dapwidgets.sidebar(dapwidgets.frames, nil, "wincmd p | split")
}

map("n", "<leader>cc", dap.continue, opts)
map("n", "<leader>ss", dap.step_over, opts)
map("n", "<leader>si", dap.step_into, opts)
map("n", "<leader>so", dap.step_out, opts)
map("n", "<leader>rc", dap.run_to_cursor, opts)
map("n", "<leader>br", dap.toggle_breakpoint, opts)
map("n", "<leader>bc", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, opts)
map("n", "<leader>bm", function() dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, opts)
map("n", "<leader>bd", dap.clear_breakpoints, opts)
map("n", "<leader>bs", function() dap.list_breakpoints() vim.cmd.copen() end, opts)
map("n", "<leader>ro", repl_open, opts)
map("n", "<leader>to", function() dapterm:open{nofocus = true} end, opts)
map("n", "<leader>rl", dap.run_last, opts)
map("n", "<leader>te", dap.terminate, opts)
map("n", "<leader>dp", function() dapwidgets.hover(nil, {border = "none"}) end, opts)
map("n", "<Leader>de", function()
    for _, bar in ipairs(sidebars) do
      bar.toggle()
      if bar.win then vim.wo[bar.win].winfixbuf = true end
      vim.bo[bar.buf].filetype = "dap-sidebar"
    end
  end,
  opts
)

-- LuaSnip
-------------------------------------------------------------------------------
local luasnip = lazy_require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

-- combined function for builtin-in and luasnip jumping
local function snipjump(direction, lhs)
  if vim.snippet.active{direction = direction} then
    return ("<cmd>lua vim.snippet.jump(%d)<cr>"):format(direction)
  elseif luasnip.jumpable(direction) then
    return ("<cmd>lua require('luasnip').jump(%d)<cr>"):format(direction)
  else
    return lhs
  end
end

local function snipchoice(direction, lhs)
  if luasnip.choice_active() then
    luasnip.change_choice(direction)
  else
    return lhs
  end
end

-- we only define mappings for jumping around, expansion is handled by insert
-- mode completion (see h: 'ins-completion' and 'completefunc' defined above).
map({"i", "s"}, "<Tab>", function() return snipjump(1, "<Tab>") end, {expr = true, unpack(opts)})
map({"i", "s"}, "<S-Tab>", function() return snipjump(-1, "<S-Tab>") end, {expr = true, unpack(opts)})
map({"i", "s"}, "<C-n>", function() return snipchoice(1, "<C-n>") end, {expr = true, unpack(opts)})
map({"i", "s"}, "<C-p>", function() return snipchoice(-1, "C-p") end, {expr = true, unpack(opts)})

-- fzf-lua
-------------------------------------------------------------------------------
local fzf = require("fzf-lua")

fzf.setup{
  hls = {
    title = "PantranTitle",
    preview_title = "PantranTitle"
  },
  winopts = {
    backdrop = 100,
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
  lsp = {jump1 = true},
  fzf_opts = {["--layout"] = "default"},
  defaults = {file_icons = not vim.g.vga_compatible}
}

-- when a count N is given to a fzf mapping called through the following
-- function, the search is started in the Nth parent directory
local function fzf_cwd(picker, args)
  local target_dir = vim.uv.fs_realpath(("../"):rep(vim.v.count) .. ".")
  fzf[picker](vim.tbl_extend("error", args or {}, {cwd = target_dir}))
end

map("n", "<leader>ff", function() fzf_cwd("files") end, opts)
map("n", "<leader>rg", function() fzf_cwd("live_grep") end, opts)
map("n", "<leader>fz", fzf.builtin, opts)

-- if fzf binary is available patch ui.select and some previous mappings
if vim.fn.executable("fzf") == 1 then
  fzf.register_ui_select()
  map("n", "<leader>ll", fzf.diagnostics_document, opts)
  map("n", "<leader>bs", fzf.dap_breakpoints, opts)

  function lsp.LspAttach(args)
    local bufopts = {buffer = args.buf, unpack(opts)}
    map("n", "grd", fzf.lsp_definitions, bufopts)
    map("n", "gri", fzf.lsp_implementations, bufopts)
    map("n", "gri", fzf.lsp_implementations, bufopts)
    map("n", "gra", fzf.lsp_code_actions, bufopts)
    map("n", "grr", fzf.lsp_references, bufopts)
    map("n", "gO", fzf.lsp_document_symbols, bufopts)
    map("n", "<localleader>gO", fzf.lsp_live_workspace_symbols, bufopts)
    map("n", "<localleader>gf", fzf.lsp_finder, bufopts)
  end
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
map("n", "<leader>tro", vim.cmd.Pantran, opts)

-- gp.nvim
-------------------------------------------------------------------------------
local def = require("gp.defaults")
def.chat_system_prompt = (def.chat_system_prompt):match("(.-)\n")
local gp = require("gp")

gp.setup{
  chat_user_prefix = "## User",
  chat_assistant_prefix = {"## Assistant", " ({{agent}})"},
  command_prompt_prefix_template = "{{agent}}: ",
  prompt_prefix_template = "{{agent}}: ",
  prompt_save = "Directory: ",
  toggle_target = "popup",
  chat_confirm_delete = false,
  chat_shortcut_respond = {modes = {"n", "v"}, shortcut = "<cr>"},
  chat_shortcut_delete = {modes = {"n", "v"}, shortcut = "<leader>gd"},
  chat_shortcut_stop = {modes = {"n", "v"}, shortcut = "<leader>gx"},
  chat_shortcut_new = {modes = {"n", "v"}, shortcut = "<leader>gn"},
}

for mode, key in pairs{n = "<cmd>", v = ":"} do
  map(mode, "<leader>gp", key .. "GpChatToggle popup<cr>", opts)
  map(mode, "<leader>gg", key .. "GpPopup<cr>", opts)
  map(mode, "<leader>gs", key .. "GpChatToggle vsplit<cr>", opts)
  map(mode, "<leader>g/", key .. "GpChatFinder<cr>", opts)

  map(mode, "<leader>gm", "<cmd>GpImage<cr>", opts)
  map(mode, "<leader>gx", "<cmd>GpStop<cr>", opts)
end

-- see :h :map-operator
local function motion_cmd(command, suffix)
  return function()
    vim.opt.operatorfunc = ([[{ -> execute("'[,']%s")}]]):format(command)
    return "g@" .. (suffix or "")
  end
end

for mapping, key in pairs{GpImplement = "<leader>gc", GpChatPaste = "<leader>gy"} do
  map({"n", "v"}, key, motion_cmd(mapping), {expr = true, unpack(opts)})
  map("n", key .. key:sub(-1), motion_cmd(mapping, "_"), {expr = true, unpack(opts)})
end

-- hack to modify style of popup window
local popup = gp.render.popup
function gp.render.popup(optbuf, title, ...)
  local buf, win, close, resize = popup(optbuf, (" %s "):format(title), ...)
  vim.opt_local.winhighlight = {Normal = "PantranNormal", FloatTitle = "PantranTitle", FloatBorder = "PantranBorder"}
  return buf, win, close, resize
end

-- }}}
-- vim: foldmethod=marker foldmarker=--\ {{{,--\ }}}
