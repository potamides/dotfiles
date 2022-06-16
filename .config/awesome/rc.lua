-------------------------------------------------------------------------------
-- {{{ Imports
-------------------------------------------------------------------------------

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
-- Standard awesome library
local awful = require("awful")
local gears = require("gears")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- low-level system libraries
local glib = require("lgi").GLib
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty       = require("naughty")
local menubar       = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- other stuff
local freedesktop  = require("freedesktop")
local modalawesome = require("modalawesome")
local utils        = require("utils")
local battery      = require("widgets.battery")
local volume       = require("widgets.volume")
local playback     = require("widgets.playback")
local net_widget   = require("widgets.net")
local run_shell    = require("widgets.run-shell")
local xrandr       = require("xrandr")
local unpack       = unpack or table.unpack -- luacheck: globals unpack (compatibility with Lua 5.1)

-- }}}
-------------------------------------------------------------------------------
-- {{{ Error handling
-------------------------------------------------------------------------------

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
  title = "Oops, there were errors during startup!",
  text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true

    naughty.notify({ preset = naughty.config.presets.critical,
    title = "Oops, an error happened!",
    text = tostring(err) })
    in_error = false
  end)
end

-- }}}
-------------------------------------------------------------------------------
-- {{{ Variable definitions
-------------------------------------------------------------------------------

-- Themes define colors, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_dir("config") .. "/themes/gruvbox/theme.lua")

-- This is used later as the default terminal, browser and editor to run.
local terminal = os.getenv("TERMCMD") or "alacritty"
local browser  = os.getenv("BROWSER") or "qutebrowser"
local editor   = os.getenv("EDITOR") or "nvim"
local editor_cmd = terminal .. " -e " .. editor .. " "

-- Set the terminal for applications that require it.
menubar.utils.terminal = terminal

-- Default modkey.
local modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  utils.layout.centerwork,
  awful.layout.suit.tile,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.fair,
  awful.layout.suit.spiral,
  awful.layout.suit.corner.nw,
  awful.layout.suit.max,
}

-- }}}
-------------------------------------------------------------------------------
-- {{{ Menu
-------------------------------------------------------------------------------

-- Create a launcher widget and a main menu
local myawesomemenu = {
  { "Hotkeys", function() return false, hotkeys_popup.show_help end},
  { "Edit Config", editor_cmd .. awesome.conffile },
  { "Restart", awesome.restart },
  { "Quit", function() awesome.quit() end},
  { "Open Terminal", terminal },
  { "Lock", function() awesome.spawn("physlock -s") end },
  { "Reboot", function() awesome.spawn("systemctl reboot") end },
  { "Shutdown", function() awesome.spawn("systemctl poweroff") end },
}

local mymainmenu = freedesktop.menu.build({
  icon_size = beautiful.menu_height,
  before = {{ "Awesome", myawesomemenu, beautiful.awesome_icon }},
})

local status_box = wibox.widget.textbox(modalawesome.active_mode.text)
local mylauncher = wibox.widget(utils.widget.compose{{
  {
    awful.widget.launcher {
      image = beautiful.archlinux_icon,
      menu  = { toggle = function()
          mymainmenu:toggle {
            coords = {
              x = beautiful.gap,
              y = beautiful.wibar_height + beautiful.gap
            }
          }
        end
      }
    },
    status_box,
    spacing = beautiful.gap,
    layout  = wibox.layout.fixed.horizontal,
  },
  shape = utils.shape.rightangled.left,
  color = beautiful.lightaqua,
  margin = beautiful.small_gap
}})

modalawesome.active_mode:connect_signal("widget::redraw_needed", function()
  local text, color = modalawesome.active_mode.text

  if     text == 'tag'      then color = beautiful.lightaqua
  elseif text == 'layout'   then color = beautiful.lightgreen
  elseif text == 'client'   then color = beautiful.lightblue
  elseif text == 'launcher' then color = beautiful.lightyellow
  end

  mylauncher:set_bg(color)
  status_box:set_markup(beautiful.widget_markup:format(beautiful.bg_normal, string.upper(text)))
  beautiful.taglist_bg_focus = color

  -- use of undocumented function :(
  for s in screen do s.mytaglist._do_taglist_update() end
end)

-- menu of clients that match a particular rule.
local function clientmenu(filter, selected_tags_only)
  local scr, items, clients = awful.screen.focused(), {
    theme = {
      width        = beautiful.clientsmenu_width,
      border_color = beautiful.clientsmenu_border_color
    }
  }

  if selected_tags_only then
    clients = gears.table.join(unpack(gears.table.map(function(t) return t:clients() end, scr.selected_tags)))
  else
    clients = client.get()
  end

  for c in gears.table.iterate(clients, function(c) return awful.rules.match(c, filter) end) do
    table.insert(items, {
      c.name,
      function() c:jump_to() end,
      -- most clients which do not have an icon are terminal applications
      c.icon or menubar.utils.lookup_icon("terminal")
    })
  end

  table.sort(items, function(a, b) return a[1] <= b[1] end)
  local menu, geom = awful.menu(items), scr.geometry
  menu:show{
    coords = {
      x = geom.x + (geom.width - menu.width) / 2,
      y = geom.y + (geom.height - menu.height) / 2
    }
  }
end

-- }}}
-------------------------------------------------------------------------------
-- {{{ Wibar
-------------------------------------------------------------------------------

-- Clock
-------------------------------------------------------------------------------
-- Create a textclock widget and attach a calendar to it
local mytextclock = wibox.widget.textclock(beautiful.widget_markup:format(beautiful.bg_normal, "%H:%M"), 60)
local month_calendar = awful.widget.calendar_popup.month {
  long_weekdays = true,
  margin = beautiful.gap
}

mytextclock:connect_signal("mouse::enter", function()
  month_calendar:call_calendar(0, "tr", awful.screen.focused())
  month_calendar.visible = true
end)
mytextclock:connect_signal("mouse::leave", function()
  month_calendar.visible = false
end)
mytextclock:buttons(gears.table.join(
  awful.button({ }, 1, function() month_calendar:call_calendar(-1) end),
  awful.button({ }, 3, function() month_calendar:call_calendar( 1) end)
))

-- Wallpaper
-------------------------------------------------------------------------------
local function set_wallpaper(s)
  if beautiful.wallpaper then
      utils.wallpaper.repeated(beautiful.wallpaper, s)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- Widget Initialization
-------------------------------------------------------------------------------
volume.init()
battery.init()
net_widget.init()
playback.init()

-- create new playback widgets for each screen so that mouse feedback isn't shown in every wibar
function playback.create_widget()
  local title = playback.text
  local widget = wibox.widget(gears.table.crush(utils.widget.compose{{
    {
      title,
      max_size = beautiful.playback_width,
      speed = 70,
      step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
      layout = wibox.container.scroll.horizontal,
    },
    shape = utils.shape.parallelogram.left,
    color = beautiful.bg_focus,
    margin = beautiful.small_gap,
  }},
  {
    opacity = 0,
    buttons = awful.button({ }, 1, function(self)
      self.widget.bg = beautiful.playback_bg_press
      if #title.text > 0 then
        -- save titles of interesting songs for later, useful for radio streams
        local songlist = io.open(os.getenv("HOME") .. "/Documents/songlist", "a+")
        if not string.find(songlist:read("*a"), title.text, 1, true) then
          songlist:write(title.text .. "\n")
        end
        songlist:close()
      end
    end,
    function(self) self.widget.bg = beautiful.playback_bg_hover end),
  }))

  widget:connect_signal('mouse::enter', function() widget.bg = beautiful.playback_bg_hover end)
  widget:connect_signal('mouse::leave', function() widget.bg = beautiful.playback_bg_normal end)
  title:connect_signal("widget::redraw_needed", function() widget.opacity = #title.text > 0 and 1 or 0 end)

  return widget
end

-- Taglist
-------------------------------------------------------------------------------
-- Each screen has its own tag table.
local tags = { "❶", "❷", "❸", "❹", "❺", "❻" }

-- Assign the buttons for the taglist
local taglist_buttons = gears.table.join(
awful.button({ }, 1, function(t) t:view_only() end),
awful.button({ modkey }, 1, function(t)
  if client.focus then
    client.focus:move_to_tag(t)
  end
end),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, function(t)
  if client.focus then
    client.focus:toggle_tag(t)
  end
end),
awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local widget_template = {
  {
    {
      id     = 'text_role',
      widget = wibox.widget.textbox,
    },
    left  = beautiful.big_gap,
    right = beautiful.big_gap,
    widget = wibox.container.margin
  },
  id     = 'background_role',
  widget = wibox.container.background,
  -- Add support for hover colors
  create_callback = function(self, tag)
    local bg_empty = table.concat{gears.color(beautiful.taglist_bg_empty):get_rgba()}
    local bg_occupied = table.concat{gears.color(beautiful.taglist_bg_occupied):get_rgba()}
    local bg_hover = table.concat{gears.color(beautiful.taglist_bg_hover):get_rgba()}
    self:connect_signal('mouse::enter', function()
      local bg = table.concat{self.bg:get_rgba()}
      if  bg == bg_empty or bg == bg_occupied then
        self.bg = beautiful.taglist_bg_hover
      end
    end)
    self:connect_signal('mouse::leave', function()
      if table.concat{self.bg:get_rgba()} == bg_hover then
        self.bg = #tag:clients() == 0 and beautiful.taglist_bg_empty or beautiful.taglist_bg_occupied
      end
    end)
  end,
}

awful.screen.connect_for_each_screen(function(s)
  -- Wallpaper
  set_wallpaper(s)

  -- Taglist
  local ultrawide, highres = s.geometry.width / s.geometry.height > 2, s.geometry.height >= 1440
  for index, tag in ipairs(tags) do
    awful.tag.add(tag, {
      layout   = awful.layout.layouts[ultrawide and 1 or 2],
      gap      = highres and beautiful.useless_gap or 0,
      screen   = s,
      selected = index == 1,
    })
  end

  -- Create an imagebox widget which will contain an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(gears.table.join(
  awful.button({ }, 1, function() awful.layout.inc( 1) end),
  awful.button({ }, 3, function() awful.layout.inc(-1) end),
  awful.button({ }, 4, function() awful.layout.inc( 1) end),
  awful.button({ }, 5, function() awful.layout.inc(-1) end)))
  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist{
    screen = s,
    filter = awful.widget.taglist.filter.all,
    style  = {
      shape = utils.shape.parallelogram.left
    },
    layout = {
      spacing = beautiful.negative_gap,
      layout  = wibox.layout.grid.horizontal
    },
    widget_template = widget_template,
    buttons = taglist_buttons
  }

-- Wibar
-------------------------------------------------------------------------------
  -- Create the wibar
  s.mywibox = awful.wibar({position = "top", screen = s, height = beautiful.wibar_height})
  --global titlebar title container
  s.title_container = wibox.container.margin()
  -- global titlebar buttons contianer
  s.buttonsbox_container = wibox.container.margin()

  -- add widgets to the wibar
  s.mywibox:setup {
    { -- Left widgets
      mylauncher,
      s.mytaglist,
      playback.create_widget(),
      spacing = beautiful.negative_gap,
      layout = wibox.layout.fixed.horizontal,
    },
    { -- Middle widgets
      s.title_container,
      layout = wibox.layout.align.horizontal,
    },
    { -- Right widgets
      wibox.container.margin(modalawesome.sequence, beautiful.gap, beautiful.big_gap),

      -- Internet Widget
      utils.widget.compose{
        {
          net_widget.text,
          color = beautiful.fg_normal,
          shape = utils.shape.parallelogram.right
        },
        {
          net_widget.image,
          color = beautiful.bg_focus,
          shape = utils.shape.parallelogram.right,
          margin = beautiful.gap,
        }
      },

      -- Audio Volume
      utils.widget.compose{
        {
          volume.text,
          color = beautiful.fg_normal,
          shape = utils.shape.parallelogram.right
        },
        {
          volume.image,
          color = beautiful.bg_focus,
          shape = utils.shape.parallelogram.right,
          margin = beautiful.gap,
        }
      },

      -- Battery Indicator
      utils.widget.compose{
        {
          battery.text,
          color = beautiful.fg_normal,
          shape = utils.shape.parallelogram.right
        },
        {
          battery.image,
          color = beautiful.bg_focus,
          shape = utils.shape.parallelogram.right,
          margin = beautiful.gap,
        }
      },

      -- Clock / Layout / Global Titlebar Buttons
      utils.widget.compose{
        {
          mytextclock,
          color = beautiful.fg_normal,
          shape = utils.shape.parallelogram.right
        },
        {
          {
            s.mylayoutbox,
            s.buttonsbox_container,
            spacing = beautiful.small_gap,
            layout = wibox.layout.fixed.horizontal
          },
          color = beautiful.bg_focus,
          shape = utils.shape.rightangled.right,
          margin = beautiful.gap,
        }
      },

      spacing = beautiful.negative_gap,
      fill_space = true,
      layout = wibox.layout.fixed.horizontal,
    },
    expand = "none",
    layout = wibox.layout.align.horizontal,
  }
end)

-- }}}
-------------------------------------------------------------------------------
-- {{{ Bindings
-------------------------------------------------------------------------------

local clientbuttons = gears.table.join(
  awful.button({ }, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
  end),
  awful.button({ modkey }, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
    awful.mouse.client.move(c)
  end),
  awful.button({ modkey }, 3, function(c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
    awful.mouse.client.resize(c)
  end)
)

-- Initialize modalawesome & customize modes
-------------------------------------------------------------------------------
local modes = require("modalawesome.modes")

local keybindings = {
  -- Media keys
  {{}, "XF86AudioMute", volume.toggle},
  {{}, "XF86AudioLowerVolume", volume.lower},
  {{}, "XF86AudioRaiseVolume", volume.raise},
  {{}, "XF86AudioMicMute", function() awful.spawn("amixer set Capture toggle") end},
  {{}, "XF86MonBrightnessDown", function() awful.spawn("xbacklight -dec 10") end},
  {{}, "XF86MonBrightnessUp", function() awful.spawn("xbacklight -inc 10") end},
  {{}, "XF86Display", xrandr.show},
  {{}, "XF86Tools", function() awful.spawn(editor_cmd .. awesome.conffile) end},
}

modes.tag = gears.table.join(
  {
    {
      description = "show all clients on screen",
      pattern = {'s', 's'},
      handler = function() clientmenu{focusable = true} end
    },
    {
      description = "show all clients on current tag",
      pattern = {'s', 't'},
      handler = function() clientmenu({}, true) end
    },
    {
      description = "hide all visible clients until keypress",
      pattern = {'d'},
      handler = function(mode)
        local tags_ = awful.screen.focused().selected_tags
        local grabber

        awful.tag.viewnone(awful.screen.focused())
        mode.grabber:stop()

        grabber = awful.keygrabber {
          autostart = true,
          keypressed_callback = function()
            awful.tag.viewmore(tags_)
            grabber:stop()
            mode.grabber:start()
          end
        }
      end,
    },
    {
      description = "focus client by index",
      pattern = {'%d*', '[,.]'},
      handler = function(_, count, direction)
        count = count == '' and 1 or tonumber(count)

        if direction == '.' then
          awful.client.focus.byidx(count)
        else
          awful.client.focus.byidx(-count)
        end
      end
    },
  },
  modes.tag
)

modes.launcher = gears.table.join(
  {
    {
      description = "lower volume",
      pattern = { "F1" },
      handler = volume.lower
    },
    {
      description = "raise volume",
      pattern = { "F2" },
      handler = volume.raise
    },
    {
      description = "toggle volume",
      pattern = { "F3" },
      handler = volume.toggle
    },
    {
      description = "toggle mic",
      pattern = { "F4" },
      handler = function() awful.spawn("amixer set Capture toggle") end
    },
    {
      description = "decrease backlight",
      pattern = { "F5" },
      handler = function() awful.spawn("xbacklight -dec 10") end
    },
    {
      description = "increase backlight",
      pattern = { "F6" },
      handler = function() awful.spawn("xbacklight -inc 10") end
    },
    {
      description = "switch monitor setup",
      pattern = { "F7" },
      handler = xrandr.show
    },
    {
      description = "launch ranger",
      pattern = {'f'},
      handler = function() awful.spawn(terminal.." -e ranger") end
    },
    {
      description = "take screenshot",
      pattern = {'c'},
      handler = function()
        local sgeo = awful.screen.focused().geometry
        local boxflag = string.format("--autoselect %s,%s,%s,%s", sgeo.x, sgeo.y, sgeo.width, sgeo.height)
        local path = os.getenv("HOME") .. "/Pictures/Screenshots/Screenshot-%Y%m%d-%H%M%S.png"

        awful.spawn.easy_async(string.format("scrot %s %s", boxflag, path), function()
          naughty.notify({ text = "Took screenshot." })
        end)
      end
    },
    {
      description = "launch browser",
      pattern = {'b'},
      handler = function() awful.spawn(browser) end
    },
    {
      description = "launch keepassxc",
      pattern = {'k'},
      handler = function() awful.spawn.raise_or_spawn("keepassxc") end
    },
    {
      description = "lock screen",
      pattern = {'l'},
      handler = function() awful.spawn("physlock -s", false) end
    },
    {
      description = "launch ncmpcpp",
      pattern = {'n'},
      handler = function()
        local host = os.getenv("MPD_HOST") or "localhost"
        local port = os.getenv("MPD_PORT") or 6600

        awful.spawn.raise_or_spawn(terminal .. " -e ncmpcpp --host " .. host .. " --port " .. port)
      end
    },
    {
      description = "toggle mpd playback",
      pattern = {'p'},
      handler = function() playback.mpd.toggle() end
    },
    {
      description = "lua execute prompt",
      pattern = {'x'},
      handler = function()
        run_shell.launch{
          prompt = 'Lua: ',
          exe_callback = awful.util.eval,
          history_path = awful.util.get_cache_dir() .. "/history_eval"
        }
      end,
    },
    {
      description = "run prompt",
      pattern = {'s'},
      handler = function()
        run_shell.launch{
          prompt = 'Run: ',
          completion_callback = awful.completion.shell,
          history_path = awful.util.get_cache_dir() .. "/history",
          exe_callback = function(cmd)
            awful.spawn.easy_async_with_shell(cmd, function(stdout, stderr, _, code)
              if code ~= 0 then
                naughty.notify({ preset = naughty.config.presets.critical,
                  timeout = naughty.config.defaults.timeout,
                  text = stderr ~= "" and stderr:gsub("%s$", "") or
                    "Command terminated with exit code " .. code .. "!"})
              elseif stdout ~= "" then
                naughty.notify({ text = stdout:gsub("%s$", "")})
              end
            end)
          end,
          hooks = {
            -- Launch command on dedicated GPU
            {{'Shift'}, 'Return', function(command)
              return  "DRI_PRIME=1 " .. command
            end},
          }
        }
      end
    },
    {
      description = "execute duckduckgo search",
      pattern = {'d'},
      handler = function(mode)
        run_shell.launch{
          prompt = 'DDG: ',
          exe_callback = function(command)
            local search = " https://duckduckgo.com/?q=" .. command:gsub('%s', '+')
            awful.spawn.easy_async(browser .. search, function()
              local find_browser = function(c) return awful.rules.match(c, {class = browser, urgent = true}) end
              local browser_instance = awful.client.iterate(find_browser)()
              browser_instance:jump_to()
              mode.stop()
            end)
          end,
        }
      end
    },
    {
      description = "show the menubar",
      pattern = {'m'},
      handler = function()
        local sgeo = awful.screen.focused().geometry
        menubar.show_categories = false
        menubar.geometry.height = beautiful.wibar_height
        menubar.geometry.y = sgeo.y + sgeo.height - menubar.geometry.height - 2 * beautiful.menubar_border_width
        menubar.show()
      end
    },
  },
  modes.launcher
)

modalawesome.init{
  modkey      = modkey,
  modes       = modes,
  keybindings = keybindings,
}

-- }}}
-------------------------------------------------------------------------------
-- {{{ Rules & Filters
-------------------------------------------------------------------------------

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  { rule = { },
    properties = {
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap+awful.placement.no_offscreen,
      size_hints_honor = false,
    }
  },

  -- Browser & keepassxc always on tag 1
  { rule_any = { class = { browser, "KeePassXC" }},
    except_any = { name = { "Unlock Database - KeePassXC", "Auto-Type - KeePassXC" }},
    properties = { tag = tags[1] }},

  -- Spawn keepassxc prompts on tags were they were called (which they don't do by default)
  { rule_any = { name = { "Unlock Database - KeePassXC", "Auto-Type - KeePassXC" }},
    properties = { tag = function() return awful.screen.focused().selected_tag end }},

  -- dirty hack to preven Ctrl-q from closing firefox
  { rule = { class = "firefox" },
    properties = { keys = awful.key({ "Control" }, "q", function() end) }},

  -- Make dragon sticky for easy drag and drop in ranger
  { rule = { class = "Dragon-drag-and-drop" },
    properties = { ontop = true, sticky = true }},

  -- askpass has wrong height on multi-screen setups somehow
  { rule = { class = "Git-gui--askpass" },
    properties = { height = 200 }},

  -- some applications like password prompt for keepassxc autotype should be floating and centered
  { rule_any = { name = { "Unlock Database - KeePassXC", "Auto-Type - KeePassXC" }, class = { "Git-gui--askpass" }},
    properties = { floating = true, placement = awful.placement.centered }},

  -- always put ncmpcpp on last tag
  { rule = { name = "ncmpcpp.*" },
    properties = { tag = tags[#tags] }},

  -- display keyboard (and mouse) status nicely
  { rule = { class = "Key-mon" },
    properties = { placement = awful.placement.bottom, sticky = true, floating = true, focusable = false }},

  -- honor size hints of mpv video player
  { rule = { class = "mpv" },
    properties = { size_hints_honor = true }},

  -- quickfix for screen blanking inhibition in qutebrowser (https://github.com/qutebrowser/qutebrowser/issues/5504)
  { rule = { class = "qutebrowser" },
    callback = function(c)
      c:connect_signal("property::fullscreen", function()
        awful.spawn(c.fullscreen and "xset -dpms s off" or "xset +dpms s on", false)
      end)
    end
  },

  -- place conky in background on primary screen
  { rule = { class = "conky" },
    properties = { focusable = false, screen = function() return screen.primary end,
      placement = awful.placement.restore, new_tag = { hide = true, volatile = true }},
    callback = function()
      if not awful.rules.conky_signals_connected then
        local function conky_restart()
          awful.spawn("killall -SIGUSR1 conky", false)
        end

        -- restart conky when a screen is removed or its geometry changes, or when awesome restarts
        screen.connect_signal("property::geometry", conky_restart)
        screen.connect_signal("removed", conky_restart)
        awesome.connect_signal("exit", conky_restart)

        awful.rules.conky_signals_connected = true
      end
    end
  },

  -- super ugly hack to hide menubar in qpdfview which is not possible (yet)
  -- through its configuration options (see https://answers.launchpad.net/qpdfview/+question/681572)
  { rule = { class = "qpdfview" },
    callback = function(c)
      if not c.transient_for then
        local function hide_menu_bar()
          -- we need to do wait until the end of the next main loop because
          -- the actual SetInputFocus request is only send to the X11 server at
          -- the end of the current main loop iteration (thanks psychon for
          -- figuring this out)
          utils.timer.next_main_loop(function()
            local kb = awful.keygrabber.current_instance
            if kb then kb:stop() end
            -- execute qpdfview keybinding which hides menu bar
            awful.key.execute({"Control"}, "m")
            if kb then kb:start() end
          end)
          c:disconnect_signal("focus", hide_menu_bar)
        end
        c:connect_signal("focus", hide_menu_bar)
      end
  end}
}

-- filter for qpdfview to prevent focus stealing after compiling latex documents
awful.ewmh.add_activate_filter(function(c)
  if c.class == "qpdfview" then
    return false
  end
end, "ewmh")

-- }}}
-------------------------------------------------------------------------------
-- {{{ Signals
-------------------------------------------------------------------------------

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
  if awesome.startup and
    not c.size_hints.user_position
    and not c.size_hints.program_position then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  else
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    awful.client.setslave(c)
  end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
  -- buttons for the titlebar
  local buttons = gears.table.join(
    awful.button({ }, 1, function()
      c:emit_signal("request::activate", "titlebar", {raise = true})
      awful.mouse.client.move(c)
    end),
    awful.button({ }, 3, function()
      c:emit_signal("request::activate", "titlebar", {raise = true})
      awful.mouse.client.resize(c)
    end)
  )

  awful.titlebar(c, {size = beautiful.titlebar_height, position = "bottom"}):setup {
    nil,
    nil,
    {
      awful.titlebar.widget.floatingbutton(c),
      left = beautiful.gap,
      right = beautiful.gap + beautiful.small_gap,
      top = beautiful.gap,
      bottom = beautiful.gap,
      widget = wibox.container.margin
    },
    buttons = buttons,
    layout = wibox.layout.align.horizontal
  }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- smart border
-------------------------------------------------------------------------------
local function update_borders(s, t)
  local max = awful.layout.get(s).name == "max"
  local only_one = #s.tiled_clients == 1 -- use tiled_clients so that other floating windows don't affect the count
  local nogap = t.gap == 0 or (only_one and not t.gap_single_client)

  -- but iterate over clients instead of tiled_clients as tiled_clients doesn't include maximized windows
  for _, c in pairs(s.clients) do
    if (max or only_one) and nogap and not c.floating or c.maximized or not c.focusable then
      c.border_width = 0
    else
      c.border_width = beautiful.border_width
    end
  end
end

local function update_borders_by_client(c)
  if c.screen and c.screen.selected_tag then
    update_borders(c.screen, c.screen.selected_tag)
  end
end

local function update_borders_by_tag(t)
  if t.screen then
    update_borders(t.screen, t)
  end
end

-- this is definitely not optimal, but as good as it gets (https://github.com/awesomeWM/awesome/issues/2518)
for _, signal in pairs({"%sfloating", "%sfullscreen", "%smaximized_vertical", "%smaximized_horizontal", "%smaximized",
  "%sminimized", "%shidden", "manage", "unmanage"}) do
  client.connect_signal(string.format(signal, "property::"), update_borders_by_client)
end

for _, signal in pairs({"%sselected", "%sactivated", "tagged"}) do
  tag.connect_signal(string.format(signal, "property::"), update_borders_by_tag)
end

client.connect_signal("property::screen", function(c, old_screen)
  update_borders_by_client(c)
  if old_screen and old_screen.selected_tag then
    update_borders(old_screen, old_screen.selected_tag)
  end
end)

client.connect_signal("focus", function(c)
  c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
  c.border_color = beautiful.border_normal
end)

-- global titlebar
-------------------------------------------------------------------------------
local function title_create(c)
  return wibox.widget {
    markup = "<b>" .. (c.class or "client") .. "</b>",
    align = "center",
    widget = wibox.widget.textbox,
  }
end

local function title_insert(c)
  if not c.title then
    c.title = title_create(c)
  end
  c.screen.title_container.widget = c.title
  c.title_container = c.screen.title_container
end

local function title_update(c)
  if c.title then
    c.title:set_markup("<b>" .. (c.class or "client") .. "</b>")
  end
end

local function title_remove(c)
  -- delay unsetting of titlebar text to remove flickering on change
  gears.timer.delayed_call(function(title, container)
    if title and container and container.widget == title then
      container.widget = nil
    end
  end, c.title, c.title_container)
end

client.connect_signal("property::name", title_update)
client.connect_signal("focus", title_insert)
client.connect_signal("unfocus", title_remove)

-- Update Titlbar Buttons in Wibar on focus / unfocus
--------------------------------------------------------------------------------
local function buttons_create(c)
  return wibox.widget {
    wibox.container.margin(awful.titlebar.widget.maximizedbutton(c), beautiful.small_gap, beautiful.small_gap),
    wibox.container.margin(awful.titlebar.widget.ontopbutton(c), beautiful.small_gap, beautiful.small_gap),
    wibox.container.margin(awful.titlebar.widget.stickybutton(c), beautiful.small_gap, beautiful.small_gap),
    layout = wibox.layout.fixed.horizontal
  }
end

local function buttons_insert(c)
  if not c.buttonsbox then
    c.buttonsbox = buttons_create(c)
  end
  c.screen.buttonsbox_container.widget = c.buttonsbox
  c.container = c.screen.buttonsbox_container
end

local function buttons_remove(c)
  -- delay removal for smoother transitions
  gears.timer.delayed_call(function(buttonsbox, container)
    if buttonsbox and container and container.widget == buttonsbox then
      container.widget = nil
    end
  end, c.buttonsbox, c.container)
end

client.connect_signal("focus", buttons_insert)
client.connect_signal("unfocus", buttons_remove)

-- turn titlebar on when client is floating
-------------------------------------------------------------------------------
client.connect_signal("property::floating", function(c)
  if c.floating and not (c.maximized or c.requests_no_titlebar) then
    awful.titlebar.show(c, "bottom")
  else
    awful.titlebar.hide(c, "bottom")
  end
end)

-- }}}

-- vim: foldmethod=marker
