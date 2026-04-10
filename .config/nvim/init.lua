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

-- built-in completion
vim.opt.complete = {"o", "F", ".^5", "kspell^5"}
vim.opt.completeopt:append{"fuzzy", "menuone", "noinsert"}
vim.opt.completefunc = "v:lua.require'snipcomp'" -- custom snippet completion defined in lua/snipcomp.lua

-- show line numbers and highlight cursor line number
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

-- spell checking
vim.opt.spell = true
vim.opt.spelllang = {"en_us", "de_de", "cjk"}
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

-- quickfix to find system-installed queries
vim.opt.runtimepath:append("/usr/share/tree-sitter")

-- restore old default to silence bell for everything except the terminal
vim.opt.belloff = vim.iter(vim.fn.getcompletion("set belloff=", "cmdline"))
  :filter(function(v) return not vim.tbl_contains({"term", "all"}, v) end)
  :totable()

vim.opt.undofile = true               -- persistent undo history
vim.opt.showmode = false              -- do not show mode message on last line
vim.opt.joinspaces = false            -- insert one space when joining two sentences
vim.opt.confirm = true                -- raise dialog asking to save changes when commands like ':q' fail
vim.opt.title = true                  -- set terminal window title to something descriptive
vim.opt.foldlevel = 99                -- do not automatically close folds when editing a file
vim.o.foldtext = ''                   -- enable syntax highlighting for folds
vim.opt.guifont = "monospace"         -- set a gui font (e.g., for Neovide)
vim.opt.virtualedit = "block"         -- virtual editing in visual block mode
vim.opt.jumpoptions = "view"          -- restore view of current window when switching buffers
vim.opt.diffopt:append("inline:word") -- automatically merge adjacent diff blocks
vim.opt.shortmess:append("Ic")        -- disable intro and ins-completion messages

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

vim.g.python3_host_prog = "/usr/bin/python3" -- use system python (useful when working with virualenvs)
vim.g.vga_compatible = false                 -- VGA textmode fallback (with CP437 character set) for legacy terminals

if vim.env.TERM == "alacritty" and not vim.env.TMUX then
  vim.g.clipboard = "osc52" -- alacritty doesn't support runtime capability detection
elseif vim.env.TERM == "linux" and vim.fn.has("gui_running") == 0 then
  vim.g.vga_compatible = true
end

-- Autocmds
-------------------------------------------------------------------------------
local au = require("au") -- small wrapper around lua autocmd api

-- disable spell checking inside terminal buffers
local open = au("user_open")
function open.TermOpen()
  vim.opt_local.spelllang = ""
end

-- replace builtin message + cmdline presentation layer
function open.VimEnter()
  require('vim._core.ui2').enable{}
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
map("n", "<leader>rs", vim.cmd.restart, opts)

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
  map("n", "<localleader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
  map("n", "<localleader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
  map("n", "<localleader>wl", function() vim.print(vim.lsp.buf.list_workspace_folders()) end, bufopts)

  -- map inlay hints if supported
  if client:supports_method("textDocument/inlayHint", args.buf) then
    local hint, bufnr = vim.lsp.inlay_hint, {bufnr = args.buf}
    map("n", "grh", function() hint.enable(not hint.is_enabled(bufnr), bufnr) end, bufopts)
    hint.enable(true, bufnr)
  end

  -- enable completion if supported
  if client:supports_method("textDocument/completion", args.buf) then
    vim.lsp.completion.enable(true, client.id, args.buf, {autotrigger = true})
  end

  if client:supports_method("textDocument/inlineCompletion", args.buf) then
    vim.lsp.inline_completion.enable(true, {bufnr = args.buf})
  end

  -- enable LSP folding if supported
  if client:supports_method('textDocument/foldingRange', args.buf) then
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"
  end
end

-- enable/toggle LSP servers (also check /lsp)
-- schedule wrap added for https://github.com/neovim/neovim/issues/38302
vim.schedule_wrap(vim.lsp.enable){
  ({"pyright", "basedpyright"})[vim.fn.executable('basedpyright') + 1],
  "ruff",
  "bashls",
  "lua_ls",
  "texlab"
}

local function lsp_toggle(name)
  vim.lsp.enable(name, not vim.lsp.is_enabled(name))
end

map("n", "<leader>lt", function() lsp_toggle("ltex_plus") end, opts)
map("n", "<leader>cp", function() lsp_toggle("copilot") end, opts)

map("n", "<leader>ch", function() vim.cmd.checkhealth("vim.lsp") end, opts)

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

-- Misc
-------------------------------------------------------------------------------

-- don't ask to confirm download of missing spellfiles
require("nvim.spellfile").config{confirm = false}

-- toggle mapping for indent lines
local function toggle_indentline()
  if vim.opt_local.listchars:get()['leadmultispace'] then
    return vim.opt_local.listchars:remove('leadmultispace')
  end
  vim.opt_local.listchars:append{leadmultispace = "│" .. (" "):rep(vim.fn.shiftwidth() - 1)}
end

map("n", "<leader>il", toggle_indentline, opts)

-- integrate agent through external cli (cf. lua/agent.lua)
local agent = require("agent")
local prompts = {
  ai =  "You are a helpful assistant.",
  gr = "Assist with writing by improving grammar, clarity, structure, and style based on user instructions.",
  tr = "Assist with translation between languages. Default to English unless specified.",
}

map("n", "<leader>cc", function() agent:launch(vim.lsp.buf.list_workspace_folders()[1]) end, opts)
for mapping, prompt in pairs(prompts) do
  local expert = agent:specialize{prompt = prompt, model = "opus", isolate = true}
    map("n", "<leader>" .. mapping, function() expert:launch() end, opts)
end

map({"n", "v"}, "<leader>ts", agent.send, {expr = true, unpack(opts)})
map("n", "<leader>tss", function() return agent.send() .. "_" end, {expr = true, unpack(opts)})

-- }}}
-------------------------------------------------------------------------------
-- {{{ User-installed plugin configuration
-------------------------------------------------------------------------------
local pu = require("packutils")

vim.pack.add({
  pu.gh("unblevable/quick-scope"),
  pu.gh("NvChad/nvim-colorizer.lua"),
  pu.gh("mfussenegger/nvim-dap"),
  pu.gh("tpope/vim-fugitive"),
  pu.gh("lewis6991/gitsigns.nvim"),
  pu.gh("ibhagwan/fzf-lua"),
  pu.gh("ellisonleao/gruvbox.nvim"),
  {src = pu.gh("L3MON4D3/LuaSnip"),      data = {build = "make install_jsregexp"}},
  {src = pu.gh("neovim/nvim-lspconfig"), data = {build = pu.npm("@github/copilot-language-server")}},
  {
    src = pu.gh("nvim-lualine/lualine.nvim"),
    data = {
      patch = {
        pu.gh("nvim-lualine/lualine.nvim/pull/1134.patch"),
        pu.gh("nvim-lualine/lualine.nvim/pull/1135.patch"),
      }
    }
  },

  -- dependencies
  pu.gh("rafamadriz/friendly-snippets"), -- LuaSnip
  pu.gh("nvim-tree/nvim-web-devicons"),  -- lualine.nvim, fzf-lua
}, {confirm = false})

map("n", "<leader>ql", function() vim.pack.update(nil, { offline = true }) end, opt)
map("n", "<leader>su", function() vim.pack.update(nil, { offline = true, target = 'lockfile' }) end, opt)
map("n", "<leader>sy", function() vim.pack.update() end, opt)

-- load some plugins included with nvim
vim.cmd.packadd{"nvim.tohtml", bang=true}
vim.cmd.packadd{"nvim.undotree", bang=true}

map("n", "<leader>ut", function() require("undotree").open{command="Vexplore | enew"} end, opts)

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
  terminal_colors = vim.fn.has("gui_running") == 1,
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
  dapwidgets.sidebar(dapwidgets.scopes, nil, "Vexplore!"),
  dapwidgets.sidebar(dapwidgets.frames, nil, "wincmd p | split")
}

map("n", "<leader>cn", dap.continue, opts)
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
  elseif not vim.lsp.inline_completion.get() then
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
map({"i", "s"}, "<C-p>", function() return snipchoice(-1, "<C-p>") end, {expr = true, unpack(opts)})
map({"i", "s"}, "<C-g>", function() luasnip.unlink_current() end, opts)

-- fzf-lua
-------------------------------------------------------------------------------
local fzf = require("fzf-lua")

fzf.setup{
  hls = {
    title = "Constant",
    preview_title = "Constant"
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
    map("n", "g<c-]>", fzf.lsp_definitions, bufopts)
    map("n", "gri", fzf.lsp_implementations, bufopts)
    map("n", "gra", fzf.lsp_code_actions, bufopts)
    map("n", "grr", fzf.lsp_references, bufopts)
    map("n", "gO", fzf.lsp_document_symbols, bufopts)
    map("n", "<localleader>gO", fzf.lsp_live_workspace_symbols, bufopts)
    map("n", "<localleader>gf", fzf.lsp_finder, bufopts)
  end
end

-- }}}
-- vim: foldmethod=marker foldmarker=--\ {{{,--\ }}}
