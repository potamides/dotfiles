--[[
  Custom statusline based on lualine. Look-wise it draws some inspiration from
  lightline.vim and lightline-bufferline. Also introduces two new components
  for monitoring lsp and dap progress messages.
--]]
local lualine = require("lualine")
local component = require("lualine.component")
local buffer = require("lualine.components.buffers.buffer")
local gruvbox_dark = require("lualine.themes.gruvbox_dark")
local palette = require("gruvbox").palette

local patches, components = {}, {}
local statusline = {
  default_opts = {
    icons_enabled = false,
    hide_width = 95,
    separators = {
      component = {left = "│", right = "│"},
      section = {left = "▌", right = "▐"},
    },
    symbols = {
      edit    = "+",
      lock    = "-",
      git     = "↨",
      line    = "↕",
      error   = "‼",
      warning = "!",
      info    = "¡",
      hint    = "ï",
      dap     = "≡",
      spinner = {"-", "\\", "|", "/"},
    },
  },
}

local function is_listed(buf)
  for option, val in pairs{buflisted = false, buftype = "quickfix"} do
    if vim.api.nvim_buf_get_option(buf, option) == val then
      return false
    end
  end
  return true
end

-- By default, lualine hides unlisted buffers, but it makes an exception when
-- the unlisted buffer is the current one. This hack removes this exception and
-- makes the behavior more similar to lightline-bufferline.
function patches.buffer(opts)
  local render, name = buffer.render, buffer.name
  function buffer:render(...)
    if is_listed(self.bufnr) then
      local line, more = render(self, ...), opts.symbols.more
      if self.ellipse and more then
        self.len = self.len - 3 + vim.fn.strchars(more)
        line = line:gsub('%.%.%.(%s%%T)$', more .. '%1')
      end
      return line
    end
    self.len = 0
  end
  function buffer:name(...)
    local bufname = name(self, ...)
    return bufname == "" and "[No Name]" or bufname
  end
end

-- Automatically hide the tabline when there is only one buffer and one tab.
function patches.tabline()
  local function autohide()
    local num_tabs = #vim.api.nvim_list_tabpages()
    local num_bufs = #vim.tbl_filter(is_listed, vim.api.nvim_list_bufs())
    lualine.hide{place = {"tabline"}, unhide = math.max(num_tabs, num_bufs) > 1}
  end
  vim.api.nvim_create_autocmd({"OptionSet"}, {
    group = vim.api.nvim_create_augroup("user_lualine", {clear = true}),
    pattern = {"statusline", "tabline"},
    callback = autohide
  })
  autohide()
end

-- patch the gruvbox colorscheme to match the lightline colorscheme of
-- https://github.com/gruvbox-community/gruvbox.
function patches.colorscheme()
  gruvbox_dark.terminal = vim.deepcopy(gruvbox_dark.normal)

  gruvbox_dark.replace.a.bg = palette.bright_aqua
  gruvbox_dark.terminal.a.bg = palette.bright_green
  gruvbox_dark.command.a.bg = gruvbox_dark.normal.a.bg
  gruvbox_dark.command.b.fg = gruvbox_dark.normal.c.fg
  gruvbox_dark.normal.b.fg = gruvbox_dark.normal.c.fg

  for _, spec in pairs(gruvbox_dark) do
    spec.z = {bg = spec.a.bg, fg = spec.a.fg}
    spec.c.bg = gruvbox_dark.normal.c.bg
    spec.c.fg = gruvbox_dark.normal.c.fg
  end

  gruvbox_dark.visual.b = {bg = palette.dark4, fg = gruvbox_dark.normal.a.fg}
end

local function get_icon()
  local buf = buffer:new{bufnr=vim.api.nvim_get_current_buf(), options={icons_enabled=true}}
  return vim.trim(buf.icon)
end

-- Modified lualine components for the statusline/tabline. Also adds two
-- entirely new components for lsp and dap status messages.
function components:setup(opts)
  self.fileformat = {"%{&ff}"}
  self.filetype = {'%{&ft!=#""?&ft:"no ft"}'}
  self.encoding = {'%{&fenc!=#""?&fenc:&enc}'}
  self.branch = {"branch", icon = opts.symbols.git}
  self.location = {"location", icon = opts.symbols.line}
  self.tabs = {"tabs", tabs_color = {active = "lualine_z_normal", inactive = "lualine_b_normal"}}
  self.filename = {"filename", symbols = {modified = opts.symbols.edit, readonly = opts.symbols.lock}}
  self.cwd = {function() return vim.fn.fnamemodify(vim.b.netrw_curdir or vim.fn.getcwd(), ":~") end}
  self.dap = {function() return require("dap").status() end, icon = opts.symbols.dap}
  self.tabs = {
    "tabs",
    tablen = 4,
    show_modified_status = false,
    max_length = function() return vim.o.columns end,
    tabs_color = {active = "lualine_z_normal", inactive = "lualine_b_normal"}
  }
  self.buffers = {
    "buffers",
    buflen = vim.fn.strchars(opts.symbols.more or "...") + 3,
    symbols = {alternate_file = "", modified = " " .. opts.symbols.edit},
    buffers_color = {active = "lualine_z_normal", inactive = "lualine_b_normal"},
    max_length = function()
      return vim.o.columns - self.buffers.buflen * 2 - self.tabs.tablen * vim.fn.tabpagenr("$")
    end
  }
  self.diagnostics = {
    "diagnostics",
    symbols = {
      error = opts.symbols.error .. " ",
      warn = opts.symbols.warning .. " ",
      info = opts.symbols.info .. " ",
      hint = opts.symbols.hint .. " "
    }
  }

  if opts.icons_enabled then
    function self.filename.fmt(str)
      return vim.trim(("%s %s"):format(get_icon(), str))
    end
  end

  local lsp_progress = component:extend()
  function lsp_progress:init(...)
    self.super.init(self, ...)
    self.index = 1
    self.timer = vim.loop.new_timer()
    self.timeout = 75
  end

  function lsp_progress.update_status()
    for _, client in ipairs(vim.lsp.get_clients()) do
      if not vim.tbl_isempty(client.progress.pending) then
        local msg = vim.tbl_values(client.progress.pending)[1]
        return #msg > 0 and msg or "Loading"
      end
    end
  end

  function lsp_progress:apply_icon()
    if #self.status > 0 then
      if self.timer:get_due_in() == 0 then
        self.timer:start(self.timeout, 0, vim.schedule_wrap(function()
          self.index = self.index % #opts.symbols.spinner + 1
          lualine.refresh{scope = "window"}
        end))
      end
      self.status = opts.symbols.spinner[self.index] .. " " .. self.status
    else
      self.index = 1
    end
  end

  self.lsp_progress = {lsp_progress}
  setmetatable(self, {__index = function(_, key) return key end})
end

function statusline.setup(opts)
  opts = vim.tbl_deep_extend("force", statusline.default_opts, opts or {})
  statusline.opts = opts

  components:setup(opts)
  patches.buffer(opts)
  patches.colorscheme()

  -- hide components when the window is narrow
  local function hide(comp)
    local fmt = comp.fmt
    function comp.fmt(str)
      if vim.fn.winwidth(0) < opts.hide_width then
        return ""
      end
      return fmt and fmt(str) or str
    end
    return comp
  end

  -- shorten the path when it is longer than the window
  local function pathshorten(comp)
    function comp.fmt(dir)
      -- use -2 to account for padding
      local shorten = vim.fn.winwidth(0) - 2 < vim.fn.strdisplaywidth(dir)
      return shorten and vim.fn.pathshorten(dir) or dir
    end
    return comp
  end

  lualine.setup{
    extensions = {
      -- special statusline for netrw that only shows the path
      {sections = {lualine_c = {pathshorten(components.cwd)}}, filetypes = {"netrw"}}
    },
    options = {
      theme = opts.theme,
      icons_enabled = opts.icons_enabled,
      component_separators = opts.separators.component,
      section_separators = opts.separators.section,
    },
    sections = {
      lualine_a = {components.mode},
      lualine_b = {components.filename},
      lualine_c = {hide(components.branch), components.lsp_progress, hide(components.dap), components.diagnostics},
      lualine_x = {hide(components.fileformat), hide(components.encoding), components.filetype},
      lualine_y = {components.progress},
      lualine_z = {components.location}
    },
    inactive_sections = {
      lualine_c = {{"filename", file_status = false}},
      lualine_x = {"location"},
    },
    tabline = {
      lualine_a = {components.buffers},
      lualine_z = {components.tabs}
    }
  }

  patches.tabline()
end

return statusline
