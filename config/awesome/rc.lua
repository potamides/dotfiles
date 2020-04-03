-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- other stuff
local freedesktop = require("freedesktop")
beautiful.init(gears.filesystem.get_dir("config") .. "/themes/gruvbox/theme.lua")
-- import this stuff after theme initialisation for proper colors
local wibarutil = require("wibarutil")
local battery = require("battery")
local volume = require("volume")
local revelation = require("revelation")
local mpd = require("mpd")
local net_widgets = require("net_widgets")
local run_shell = require("run_shell")
local vimawesome = require("vimawesome")
revelation.init()

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
local terminal         = "kitty"
local editor           = os.getenv("EDITOR") or "nvim"
local editor_cmd       = terminal .. " -e " .. editor
local browser          = "firefox"
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
awful.util.shell       = "/usr/bin/zsh"
-- }}}

-------------------------------------------------------------------------------
-- {{{ Menu
-------------------------------------------------------------------------------

-- Table of layouts to cover with awful.layout.inc, order matters.
-------------------------------------------------------------------------------
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
-- awful.layout.suit.corner.nw,
-- awful.layout.suit.corner.ne,
-- awful.layout.suit.corner.sw,
-- awful.layout.suit.corner.se,
}

-- Launcher
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
    icon_size = beautiful.menu_height or 10,
    before = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        -- other triads can be put here
    },
    after = {
    }
})


local status_box = wibox.widget.textbox(vimawesome.active_mode.text)
local mylauncher = wibarutil.create_parallelogram(
    {
        awful.widget.launcher {
            image = beautiful.archlinux_icon,
            menu = mymainmenu
        },
        status_box,
        spacing = 4,
        layout = wibox.layout.fixed.horizontal,
    },
    wibarutil.leftmost_parallelogram,
    beautiful.lightblue, 2)

vimawesome.active_mode:connect_signal("widget::redraw_needed",
  function()
    local text = vimawesome.active_mode.text
    status_box:set_markup(
      string.format(
        "<span color=%q><b>%s</b></span>",
        beautiful.bg_normal,
        string.upper(text)
      )
    )

    if     text == 'tag'      then mylauncher:set_bg(beautiful.lightblue)
    elseif text == 'layout'   then mylauncher:set_bg(beautiful.lightgreen)
    elseif text == 'client'   then mylauncher:set_bg(beautiful.lightpurple)
    elseif text == 'launcher' then mylauncher:set_bg(beautiful.lightyellow)
    end
end
)

-- Clock
-------------------------------------------------------------------------------
-- Create a textclock widget and attach a calendar to it
local mytextclock = wibox.widget.textclock(
    string.format("<span color=%q><b>%%H:%%M</b></span>", beautiful.bg_normal), 60)
local month_calendar = awful.widget.calendar_popup.month()
month_calendar:attach(mytextclock)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    local wallpaper = awful.util.getdir("config").."/themes/gruvbox/wall.png"
    gears.wallpaper.maximized(wallpaper, s, true)

    -- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
    screen.connect_signal("property::geometry", function(s)
        -- Wallpaper
        if beautiful.wallpaper then
            wallpaper = beautiful.wallpaper
            -- If wallpaper is a function, call it with the screen
            if type(wallpaper) == "function" then
                wallpaper = wallpaper(s)
            end
            gears.wallpaper.maximized(wallpaper, s, true)
        end
    end)

-- Taglist, Prompt & layoutbox
-------------------------------------------------------------------------------
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

    -- Each screen has its own tag table.
    local tags = { "❶", "❷", "❸", "❹", "❺", "❻"}
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
        spacing = -5,
        layout  = wibox.layout.grid.horizontal
    },
    widget_template = {
        {
                {
                    id     = 'text_role',
                    widget = wibox.widget.textbox,
                },
            left  = 14,
            right = 14,
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
    },
    buttons = taglist_buttons
}

-- Systray
-------------------------------------------------------------------------------
    local systray = wibox.widget.systray()
    beautiful.systray_icon_spacing = 7

-- global title bar    ------ holgerschurig.de/en/awesome-4.0-global-titlebar/
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
    client.connect_signal("unfocus", function (c) s = awful.screen.focused() s.mytitle:set_text("") end)

    local wireless_widgets = net_widgets.indicator({indent = 0, widget = false, interface="wlp5s0",
        interfaces={"enp3s0"}})
-- Wibar
-------------------------------------------------------------------------------
    -- Create the wibar
    s.mywibox = awful.wibar({position = "top", screen = s, height = 22})

    s.titlebar_buttons = wibox.widget {
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
            spacing = -5,
            layout = wibox.layout.fixed.horizontal,
        },
        { -- Middle widgets
            s.mytitle,
            layout = wibox.layout.align.horizontal,
        },
        { -- Right widgets
            wibox.layout.margin(vimawesome.sequence, 5, 5, 2, 2),
            wibox.layout.margin(systray, 5, 5, 2, 2),

            -- Internet Widget
            wibarutil.compose_parallelogram(
                wireless_widgets.textbox,
                wireless_widgets.imagebox,
                wibarutil.right_parallelogram,
                wibarutil.right_parallelogram),

            -- Audio Volume
            wibarutil.compose_parallelogram(
                volume.text,
                volume.img,
                wibarutil.right_parallelogram,
                wibarutil.right_parallelogram),

            -- Battery Indicator
            wibarutil.compose_parallelogram(
                battery.text,
                battery.img,
                wibarutil.right_parallelogram,
                wibarutil.right_parallelogram),

            -- Clock / Layout / Global Titlebar Buttons
            wibarutil.compose_parallelogram(
                mytextclock,
                {
                    s.mylayoutbox,
                    s.titlebar_buttons,
                    spacing = 2,
                    layout = wibox.layout.fixed.horizontal
                },
                wibarutil.right_parallelogram,
                wibarutil.rightmost_parallelogram,
                4),

            spacing = -5,
            fill_space = true,
            layout = wibox.layout.fixed.horizontal,
        },
    }
end)
-- }}}
--------------------------------------------------------------------------------
-- {{{ Mouse bindings & Key bindings
--------------------------------------------------------------------------------
local modkey = "Mod4"

local clientbuttons = gears.table.join(
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey }, 1, awful.mouse.client.move),
awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Initialize vimawesome & customize modes
-------------------------------------------------------------------------------
local keybindings = {
  -- Lenovo Thinkpad E480 function keys
  {{}, "XF86AudioMute", function () awful.spawn("amixer -D pulse set Master +1 toggle") end},
  {{}, "XF86AudioLowerVolume", function () awful.spawn("amixer -D pulse sset Master 5%-") end},
  {{}, "XF86AudioRaiseVolume", function () awful.spawn("amixer -D pulse sset Master 5%+") end},
  {{}, "XF86AudioMicMute", function () awful.spawn("amixer set Capture toggle") end},
  {{}, "XF86MonBrightnessDown", function () awful.spawn("xbacklight -dec 10") end},
  {{}, "XF86MonBrightnessUp", function () awful.spawn("xbacklight -inc 10") end},
  {{}, "XF86Display", function () awful.spawn.with_shell(gears.filesystem.get_dir("config") .. "/monitor.sh") end},
  {{}, "XF86Tools", function () awful.spawn(editor_cmd .. " " .. awesome.conffile) end},
}

local modes = require("vimawesome.modes")
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
      handler = function(self)
        local tags = awful.screen.focused().selected_tags
        local grabber

        awful.tag.viewnone(awful.screen.focused())
        self.grabber:stop()

        grabber = awful.keygrabber {
          autostart = true,
          keypressed_callback = function()
            awful.tag.viewmore(tags)
            grabber:stop()
            self.grabber:start()
          end
        }
      end,
    },
  },
  modes.tag
)

modes.launcher = gears.table.join(
  {
    {
      description = "launch ranger",
      pattern = {'f'},
      handler = function() awful.spawn(terminal.." -e ranger") end
    },
    {
      description = "take screenshot",
      pattern = {'p'},
      handler = function()
        awful.spawn.with_shell(
          "scrot 'Screenshot-%Y%m%d-%H%M%S.png' -e 'mv $f ~/Pictures/' && notify-send 'Screenshot taken.'")
        end
    },
    {
      description = "launch browser",
      pattern = {'b'},
      handler = function() awful.spawn(browser) end
    },
    {
      description = "lock screen",
      pattern = {'L'},
      handler = function() awful.spawn("physlock -s") end
    },
    {
      description = "launch ncmpcpp",
      pattern = {'n'},
      handler = function()
        awful.spawn(terminal.." -e " .. gears.filesystem.get_dir("config") .. "/ncmpcpp.sh",
            {tag=awful.screen.focused().tags[6]})
        mpd.reconnect()
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
        exe_callback = function(...) awful.spawn.with_shell(...) end,
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
    handler = function()
      run_shell.launch{
        prompt = 'DuckDuckGo: ',
        exe_callback = function(command)
          local search = "https://duckduckgo.com/?q=" .. command:gsub('%s', '+')
          awful.spawn.easy_async("xdg-open " .. search, function()
            local find_browser = function(c) return awful.rules.match(c, {class = browser}) end
            local browser_instance = awful.client.iterate(find_browser)()
            browser_instance:jump_to()
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
      menubar.geometry.y      = s.geometry.y + s.geometry.height - 40
      menubar.geometry.height = 20
      menubar.show_categories = false
      menubar.show(s)
    end
  },
  },
  modes.launcher
)


vimawesome.init{
  modkeys = {'Super_L', 'Alt_R'},
  modes = modes,
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
    properties = { border_width = beautiful.border_width,
    border_color = beautiful.border_normal,
    focus = awful.client.focus.filter,
    raise = true,
    buttons = clientbuttons,
    screen = awful.screen.preferred,
    placement = awful.placement.no_overlap+awful.placement.no_offscreen,
    size_hints_honor = false,
    titlebars_enabled = true
    }
       },

    -- Browser always on tag 1
    { rule = { class = browser},
      properties = { tag = awful.screen.focused().selected_tags[1]} },

    -- Make dragon sticky for easy drag and drop in ranger
    { rule = { class = "Dragon-drag-and-drop" },
      properties = { ontop = true, sticky = true } },

    -- the password prompt for keepassxc autotype should be floating
    { rule = { name = "Unlock Database - KeePassXC" },
      properties = { floating = true } },
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
        client.focus = c
        c:raise()
        awful.mouse.client.move(c)
    end),
    awful.button({ }, 3, function()
        client.focus = c
        c:raise()
        awful.mouse.client.resize(c)
    end)
    )

    awful.titlebar(c, {size = 20, position = "bottom"}) : setup {
        {
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
                wibox.container.margin(awful.titlebar.widget.floatingbutton(c), 4, 4, 4, 4),
                layout = wibox.layout.fixed.horizontal()
                },

            layout = wibox.layout.align.horizontal
        },
        right = 2,
        widget = wibox.container.margin
    }

    -- Hide the titlebar if we are not floating
    local l = awful.layout.get(c.screen)
    if not (l.name == "floating" or c.floating) or c.maximized then
        awful.titlebar.hide(c, "bottom")
        c.height = c.height - 20
    end
end)


-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)


client.connect_signal("property::fullscreen", function(c)
    if c.fullscreen then
        gears.timer.delayed_call(function()
            if c.valid then
                c:geometry(c.screen.geometry)
            end
        end)
    end
end)

-- awesome-copycats smart border
-------------------------------------------------------------------------------

-- No border for maximized clients
local function border_adjust(c)
    if c.maximized then -- no borders if only 1 client visible
        c.border_width = 0
    elseif #awful.screen.focused().clients > 1 then
        c.border_width = beautiful.border_width
        c.border_color = beautiful.border_focus
    else
        c.border_width = 0
    end
end

-- No border for maximized clients
local function border_unadjust(c)
    if c.maximized then -- no borders if only 1 client visible
        c.border_width = 0
    elseif #awful.screen.focused().clients > 1 then
        c.border_width = beautiful.border_width
        c.border_color = beautiful.border_normal
    else
        c.border_width = 0
    end
end

--------------------------------------------------------------------------------
-- titlebar buttons in taskbar
--------------------------------------------------------------------------------

-- Update Titlbar Buttons in Wibar on focus / unfocus
--------------------------------------------------------------------------------
local should_remove = true
local function buttons_remove(_)
    local s = awful.screen.focused()
    should_remove = true

    -- delay the resizing for smoother transition
    gears.timer.weak_start_new(0.05,
        function ()
            if should_remove then
                s.titlebar_buttons.visible = false
            end
         end)
end

local function buttons_insert(c)
    local s               = awful.screen.focused()
    local buttons         = s.titlebar_buttons:get_widgets_at(1, 1, 1, 3)
    local maximizedbutton = wibox.container.margin(awful.titlebar.widget.maximizedbutton(c), 2, 2)
    local ontopbutton     = wibox.container.margin(awful.titlebar.widget.ontopbutton(c), 2, 2)
    local stickybutton    = wibox.container.margin(awful.titlebar.widget.stickybutton(c), 2, 2)
    should_remove = false
    s.titlebar_buttons.visible = true

    if buttons then
        s.titlebar_buttons:replace_widget(buttons[3], maximizedbutton)
        s.titlebar_buttons:replace_widget(buttons[2], ontopbutton)
        s.titlebar_buttons:replace_widget(buttons[1], stickybutton)
    else
        s.titlebar_buttons:add_widget_at(maximizedbutton, 1, 1)
        s.titlebar_buttons:add_widget_at(ontopbutton, 1, 2)
        s.titlebar_buttons:add_widget_at(stickybutton, 1, 3)
    end
end

client.connect_signal("focus", border_adjust)
client.connect_signal("focus", buttons_insert)
client.connect_signal("property::maximized", border_adjust)
client.connect_signal("unfocus", border_unadjust)
client.connect_signal("unfocus", buttons_remove)

-- turn titlebar on when client is floating
-------------------------------------------------------------------------------
client.connect_signal("property::floating", function (c)
    if c.floating and not c.maximized then
        awful.titlebar.show(c, "bottom")
        c.height = c.height - 20
    else
        awful.titlebar.hide(c, "bottom")
    end
end)

-- turn tilebars on when layout is floating
-------------------------------------------------------------------------------
awful.tag.attached_connect_signal(awful.screen.focused(), "property::layout", function (t)
    local float = t.layout.name == "floating"
    for _,c in pairs(t:clients()) do
        c.floating = float
    end
end)


beautiful.notification_opacity=0.75
-- }}}

-------------------------------------------------------------------------------
-- {{{ Misc
-------------------------------------------------------------------------------

-- autostart some applications
-------------------------------------------------------------------------------
awful.spawn.with_shell(gears.filesystem.get_dir("config") .. "/autorun.sh")

-- memory management
-------------------------------------------------------------------------------
gears.timer {
    timeout   = 60,
    autostart = true,
    callback  = function()
        collectgarbage("collect")
    end
}
-- }}}
