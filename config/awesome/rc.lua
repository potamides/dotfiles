-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty       = require("naughty")
local menubar       = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- other stuff
local freedesktop  = require("freedesktop")
local modalawesome = require("modalawesome")
local xrandr       = require("xrandr")
beautiful.init(gears.filesystem.get_dir("config") .. "/themes/gruvbox/theme.lua")
-- import this stuff after theme initialisation for proper colors
local wibarutil   = require("wibarutil")
local battery     = require("status-widgets.battery-widget")
local volume      = require("status-widgets.volume-widget")
local mpd         = require("status-widgets.mpd-widget")
local net_widget  = require("status-widgets.net-widget")
local run_shell   = require("status-widgets.run-shell")
local revelation  = require("revelation")
revelation.init()
volume.init()
battery.init()
net_widget.init()

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
  awesome.connect_signal("debug::error", function (err)
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


-- This is used later as the default terminal and editor to run.
local terminal         = "alacritty"
local editor           = os.getenv("EDITOR") or "nvim"
local editor_cmd       = terminal .. " -e " .. editor
local browser          = "firefox"
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
awful.util.shell       = "/usr/bin/bash"

-- Default modkey.
local modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.fair,
  -- awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  -- awful.layout.suit.tile.top,
  -- awful.layout.suit.fair.horizontal,
  awful.layout.suit.spiral,
  -- awful.layout.suit.spiral.dwindle,
  -- awful.layout.suit.max,
  awful.layout.suit.max.fullscreen,
  awful.layout.suit.floating,
  -- awful.layout.suit.magnifier,
  awful.layout.suit.corner.nw,
  -- awful.layout.suit.corner.ne,
  -- awful.layout.suit.corner.sw,
  -- awful.layout.suit.corner.se,
}
-- }}}

-------------------------------------------------------------------------------
-- {{{ Wibar
-------------------------------------------------------------------------------

-- Menu
-------------------------------------------------------------------------------
-- Create a launcher widget and a main menu
local myawesomemenu = {
  { "hotkeys", function() return false, hotkeys_popup.show_help end},
  { "manual", terminal .. " -e man awesome" },
  { "edit config", editor_cmd .. " " .. awesome.conffile },
  { "restart", awesome.restart },
  { "quit", function() awesome.quit() end},
  { "open terminal", terminal },
  { "lock", function() awesome.spawn("physlock -s") end },
  { "reboot", function() awesome.spawn("systemctl reboot") end },
  { "shutdown", function() awesome.spawn("systemctl poweroff") end },
}

local mymainmenu = freedesktop.menu.build({
  icon_size = beautiful.menu_height,
  before = {
    { "Awesome", myawesomemenu, beautiful.awesome_icon },
    -- other triads can be put here
  },
  after = {
  }
})


local status_box = wibox.widget.textbox(modalawesome.active_mode.text)
local mylauncher = wibarutil.create_parallelogram(
{
  awful.widget.launcher {
    image = beautiful.archlinux_icon,
    menu  = { toggle = function() mymainmenu:toggle {
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
wibarutil.leftmost_parallelogram,
beautiful.lightaqua, beautiful.small_gap)

modalawesome.active_mode:connect_signal("widget::redraw_needed",
function()
  local color
  local text = modalawesome.active_mode.text

  status_box:set_markup( string.format( "<span color=%q><b>%s</b></span>",
    beautiful.bg_normal, string.upper(text)))

  if     text == 'tag'      then color = beautiful.lightaqua
  elseif text == 'layout'   then color = beautiful.lightgreen
  elseif text == 'client'   then color = beautiful.lightblue
  elseif text == 'launcher' then color = beautiful.lightyellow
  end

  mylauncher:set_bg(color)
  beautiful.taglist_bg_focus = color

  for s in screen do s.mytaglist._do_taglist_update() end
end
)

-- Clock
-------------------------------------------------------------------------------
-- Create a textclock widget and attach a calendar to it
local mytextclock = wibox.widget.textclock(
string.format("<span color=%q><b>%%H:%%M</b></span>", beautiful.bg_normal), 60)
local month_calendar = awful.widget.calendar_popup.month {
        long_weekdays = true,
        margin = beautiful.gap
    }
month_calendar:attach(mytextclock)

-- Wallpaper
-------------------------------------------------------------------------------
local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- Taglist
-------------------------------------------------------------------------------
-- Each screen has its own tag table.
local tags   = { "❶", "❷", "❸", "❹", "❺", "❻"}

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
  -- Add support for hover colors and an index label
  create_callback = function(self, c3, index, objects) --luacheck: no unused args
    self:connect_signal('mouse::enter', function()
      if not c3.selected then
        if self.bg ~= beautiful.bg2 then
          self.backup     = self.bg
          self.has_backup = true
        end
        self.bg = beautiful.bg2
      end
    end)
    self:connect_signal('mouse::leave', function()
      if self.has_backup and not c3.selected then
        self.bg = self.backup
      end
    end)
  end,
}

awful.screen.connect_for_each_screen(function(s)
  -- Wallpaper
  set_wallpaper(s)

  -- Taglist
  awful.tag(tags, s, awful.layout.layouts[1])
  -- Create an imagebox widget which will contain an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(gears.table.join(
  awful.button({ }, 1, function () awful.layout.inc( 1) end),
  awful.button({ }, 3, function () awful.layout.inc(-1) end),
  awful.button({ }, 4, function () awful.layout.inc( 1) end),
  awful.button({ }, 5, function () awful.layout.inc(-1) end)))
  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist {
    screen  = s,
    filter  = function(t) return t.name ~= "Revelation" and t.name ~=  "Revelation_zoom" end,
    style   = {
      shape = wibarutil.left_parallelogram
    },
    layout   = {
      spacing = beautiful.negative_gap,
      layout  = wibox.layout.grid.horizontal
    },
    widget_template = widget_template,
    buttons = taglist_buttons
  }

-- Systray
-------------------------------------------------------------------------------
  --local systray = wibox.widget.systray()

-- global title bar
-------------------------------------------------------------------------------
  s.mytitle = wibox.widget {
    align = "center",
    widget = wibox.widget.textbox,
  }
  local function update_title_text(c)
    s = awful.screen.focused()
    if c == client.focus then
      if c.class then
        s.mytitle:set_markup("<b>" .. c.class .. "</b>")
      end
    end
  end
  client.connect_signal("focus", update_title_text)
  client.connect_signal("property::name", update_title_text)
  client.connect_signal("unfocus", function () awful.screen.focused().mytitle:set_text("") end)
  client.connect_signal("property::screen", function () awful.screen.focused().mytitle:set_text("") end)

-- Wibar
-------------------------------------------------------------------------------
    -- Create the wibar
    s.mywibox = awful.wibar({position = "top", screen = s, height = beautiful.wibar_height})

    s.titlebar_buttons = wibox.widget {
        homogeneous = false,
        layout = wibox.layout.grid.horizontal
    }

    -- add widgets to the wibar
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        { -- Left widgets
            mylauncher,
            s.mytaglist,
            mpd.widget,
            spacing = beautiful.negative_gap,
            layout = wibox.layout.fixed.horizontal,
        },
        { -- Middle widgets
            s.mytitle,
            layout = wibox.layout.align.horizontal,
        },
        { -- Right widgets
            wibox.container.margin(modalawesome.sequence, beautiful.gap, beautiful.big_gap),
            --wibox.container.margin(systray, beautiful.gap, beautiful.gap, beautiful.small_gap, beautiful.small_gap),

            -- Internet Widget
            wibarutil.compose_parallelogram(
                net_widget.text,
                net_widget.image,
                wibarutil.right_parallelogram,
                wibarutil.right_parallelogram),

            -- Audio Volume
            wibarutil.compose_parallelogram(
                volume.text,
                volume.image,
                wibarutil.right_parallelogram,
                wibarutil.right_parallelogram),

            -- Battery Indicator
            wibarutil.compose_parallelogram(
                battery.text,
                battery.image,
                wibarutil.right_parallelogram,
                wibarutil.right_parallelogram),

            -- Clock / Layout / Global Titlebar Buttons
            wibarutil.compose_parallelogram(
                mytextclock,
                {
                    s.mylayoutbox,
                    s.titlebar_buttons,
                    spacing = beautiful.small_gap,
                    layout = wibox.layout.fixed.horizontal
                },
                wibarutil.right_parallelogram,
                wibarutil.rightmost_parallelogram),

            spacing = beautiful.negative_gap,
            fill_space = true,
            layout = wibox.layout.fixed.horizontal,
        },
    }
end)
-- }}}
--------------------------------------------------------------------------------
-- {{{ Mouse bindings & Key bindings
--------------------------------------------------------------------------------
local clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Initialize modalawesome & customize modes
-------------------------------------------------------------------------------
local keybindings = {
  -- Media keys
  {{}, "XF86AudioMute", volume.toggle},
  {{}, "XF86AudioLowerVolume", volume.lower},
  {{}, "XF86AudioRaiseVolume", volume.raise},
  {{}, "XF86AudioMicMute", function () awful.spawn("amixer set Capture toggle") end},
  {{}, "XF86MonBrightnessDown", function () awful.spawn("xbacklight -dec 10") end},
  {{}, "XF86MonBrightnessUp", function () awful.spawn("xbacklight -inc 10") end},
  {{}, "XF86Display", xrandr.xrandr},
  {{}, "XF86Tools", function () awful.spawn(editor_cmd .. " " .. awesome.conffile) end},
}

local modes = require("modalawesome.modes")
modes.tag = gears.table.join(
  {
    {
      description = "show all clients on screen",
      pattern = {'A'},
      handler = function() revelation() end
    },
    {
      description = "show all clients on current tag",
      pattern = {'a'},
      handler = function() revelation({curr_tag_only=true}) end
    },
    {
      description = "hide all visible clients until keypress",
      pattern = {'N'},
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
      handler = function () awful.spawn("amixer set Capture toggle") end
    },
    {
      description = "decrease backlight",
      pattern = { "F5" },
      handler = function () awful.spawn("xbacklight -dec 10") end
    },
    {
      description = "increase backlight",
      pattern = { "F6" },
      handler = function () awful.spawn("xbacklight -inc 10") end
    },
    {
      description = "switch monitor setup",
      pattern = { "F7" },
      handler = xrandr.xrandr
    },
    {
      description = "launch ranger",
      pattern = {'f'},
      handler = function() awful.spawn(terminal.." -e ranger") end
    },
    {
      description = "take screenshot",
      pattern = {'p'},
      handler = function()
        awful.spawn( "scrot 'Pictures/Screenshots/Screenshot-%Y%m%d-%H%M%S.png'", false)
        naughty.notify({ text = "Took screenshot." })
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
      handler = function() awful.spawn("keepassxc") end
    },
    {
      description = "lock screen",
      pattern = {'l'},
      handler = function() awful.spawn("physlock -s") end
    },
    {
      description = "launch ncmpcpp",
      pattern = {'n'},
      handler = function()
        local host        = os.getenv("MPD_HOST") or "localhost"
        local port        = os.getenv("MPD_PORT") or 6600
        local stream_port = os.getenv("MPD_STREAM_PORT") or 8000
        local name        = "ncmpcpp"

        -- This is unfortunately a bit hacky, but Alacritty doesn't implement the startup notification protocol
        -- https://github.com/alacritty/alacritty/issues/2824
        local find_instance = function(c) return awful.rules.match(c, {instance = name}) end
        local ncmpcpp_instance = awful.client.iterate(find_instance)()

        if ncmpcpp_instance then
          ncmpcpp_instance:jump_to()
        else
          -- temporal solution, openvpn is probably a better option than ondemand ssh forwarding
          awful.spawn(terminal .. " --class " .. name .. " -e " .. awful.util.shell .. " -c '" ..
            string.format("ssh -nTNL %s:%s:%s -L %s:%s:%s NAS & ncmpcpp --host %s --port %s'",
              port, host, port, stream_port, host, stream_port, host, port))
          mpd.reconnect()
        end
      end
    },
    {
      description = "mpd server reconnect",
      pattern = {'N'},
      handler = function() mpd.reconnect() end
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
          prompt = 'DuckDuckGo: ',
          exe_callback = function(command)
            local search = "https://duckduckgo.com/?q=" .. command:gsub('%s', '+')
            awful.spawn.easy_async("xdg-open " .. search, function()
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
        local s                 = awful.screen.focused()
        menubar.geometry.y      = s.geometry.y + s.geometry.height - 2 * beautiful.titlebar_height
        menubar.geometry.height = beautiful.titlebar_height
        menubar.show_categories = false
        menubar.show(s)
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
-- {{{ Rules
-------------------------------------------------------------------------------

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen,
            --size_hints_honor = false,
        }
    },

    -- Browser & keepassxc always on tag 1
    { rule_any = { class = {browser, "KeePassXC"}},
      except_any = { name = {"Unlock Database - KeePassXC", "Auto-Type - KeePassXC"}},
      properties = { tag = tags[1]}},

    -- dirty hack to preven Ctrl-q from closing firefox
    { rule = { class = browser},
      properties = { keys = awful.key({"Control"}, "q", function () end)}},

    -- Make dragon sticky for easy drag and drop in ranger
    { rule = { class = "Dragon-drag-and-drop" },
      properties = { ontop = true, sticky = true }},

    -- askpass has wrong height on multi-screen setups somehow
    { rule = { instance = "git-gui--askpass" },
      properties = { height = 173 }},

    -- some applications like password prompt for keepassxc autotype should be floating and centered
    { rule_any = { name = {"Unlock Database - KeePassXC"}, instance = {"git-gui--askpass"}},
      properties = { floating = true, placement = awful.placement.centered }},

    -- always put ncmpcpp on last tag
    { rule = { instance = "ncmpcpp"},
      properties = { tag = tags[#tags]}},

}
-- }}}

-------------------------------------------------------------------------------
-- {{{ Signals
-------------------------------------------------------------------------------

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
        not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
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

    awful.titlebar(c, {size = beautiful.titlebar_height, position = "bottom"}) : setup {
        { -- Left
            --awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            --[[{ -- Title
            align  = "center",
            widget = awful.titlebar.widget.titlewidget(c)
            },]]
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            wibox.container.margin(
              awful.titlebar.widget.floatingbutton(c),
              beautiful.gap, beautiful.gap + beautiful.small_gap, beautiful.gap, beautiful.gap),
            layout = wibox.layout.fixed.horizontal()
            },

        layout = wibox.layout.align.horizontal
    }
end)


-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- smart border
-------------------------------------------------------------------------------
---- No border for maximized clients or if only one tiled client
local function border_adjust(c)
    if c.maximized or (not c.floating and #awful.screen.focused().clients == 1) then
        c.border_width = 0
    else
        c.border_width = beautiful.border_width
    end
end

client.connect_signal("focus", function(c)
  border_adjust(c)
  c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
  border_adjust(c)
  c.border_color = beautiful.border_normal
end)

-- turn titlebar on when client is floating
-------------------------------------------------------------------------------
client.connect_signal("property::floating", function (c)
  if c.floating and not c.maximized then
    awful.titlebar.show(c, "bottom")
    c.height = math.min(c.height, awful.screen.focused().geometry.height - c.y)
  else
    awful.titlebar.hide(c, "bottom")
  end
  border_adjust(c)
end)

-- turn tilebars on when layout is floating
-------------------------------------------------------------------------------
awful.tag.attached_connect_signal(awful.screen.focused(), "property::layout", function (t)
    local float = t.layout.name == "floating"
    for _,c in pairs(t:clients()) do
        c.floating = float
    end
end)

-- Update Titlbar Buttons in Wibar on focus / unfocus
--------------------------------------------------------------------------------
local timer = gears.timer{timeout = 0.05, callback = function()
  awful.screen.focused().titlebar_buttons.visible = false
end}

local function buttons_remove(_)
    -- delay hiding of titlebar buttons for smoother transition
    timer:start()
end

local function buttons_insert(c)
    local s       = awful.screen.focused()
    local buttons = s.titlebar_buttons:get_widgets_at(1, 1, 1, 3)

    timer:stop()

    if not c.maximizedbutton then
      c.maximizedbutton =
        wibox.container.margin(awful.titlebar.widget.maximizedbutton(c), beautiful.small_gap, beautiful.small_gap)
    end
    if not c.ontopbutton then
      c.ontopbutton =
        wibox.container.margin(awful.titlebar.widget.ontopbutton(c), beautiful.small_gap, beautiful.small_gap)
    end
    if not c.stickybutton then
      c.stickybutton =
        wibox.container.margin(awful.titlebar.widget.stickybutton(c), beautiful.small_gap, beautiful.small_gap)
    end

    if buttons then
        s.titlebar_buttons:replace_widget(buttons[3], c.maximizedbutton)
        s.titlebar_buttons:replace_widget(buttons[2], c.ontopbutton)
        s.titlebar_buttons:replace_widget(buttons[1], c.stickybutton)
    else
        s.titlebar_buttons:add_widget_at(c.maximizedbutton, 1, 1)
        s.titlebar_buttons:add_widget_at(c.ontopbutton, 1, 2)
        s.titlebar_buttons:add_widget_at(c.stickybutton, 1, 3)
    end

    s.titlebar_buttons.visible = true
end

client.connect_signal("focus", buttons_insert)
client.connect_signal("unfocus", buttons_remove)

-- When a screen disconnects move clients to tag of same name on other screen
-- https://github.com/awesomeWM/awesome/issues/1382
-------------------------------------------------------------------------------
tag.connect_signal("request::screen",
  function(t)
    local fallback_tag = nil

    -- find tag with same name on any other screen
    for other_screen in screen do
      if other_screen ~= t.screen then
        fallback_tag = awful.tag.find_by_name(other_screen, t.name)
        if fallback_tag ~= nil then
          break
        end
      end
    end

    -- no tag with same name exists, chose random one
    if fallback_tag == nil then
      fallback_tag = awful.tag.find_fallback()
    end

    -- delete the tag and move it to other screen
    t:delete(fallback_tag, true)
  end)

-- }}}
