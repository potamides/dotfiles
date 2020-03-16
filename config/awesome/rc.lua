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

awful.util.shell="/usr/bin/zsh"

-- This is used later as the default terminal and editor to run.
local terminal = "kitty"
local editor = os.getenv("EDITOR") or "nvim"
local editor_cmd = terminal .. " -e " .. editor
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = "Mod4"
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

local startmenu = wibox.widget {
    image  = beautiful.archlinux_icon,
    resize = true,
    widget = wibox.widget.imagebox
}

startmenu:connect_signal("button::press", function(_) mymainmenu:toggle({ coords = { x = 0, y = 0 } }) end)
local mylauncher = wibox.layout.margin(startmenu, 0,0,2,2)

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
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
    awful.button({ }, 1, function () awful.layout.inc( 1) end),
    awful.button({ }, 3, function () awful.layout.inc(-1) end),
    awful.button({ }, 4, function () awful.layout.inc( 1) end),
    awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(
        s,
        awful.widget.taglist.filter.all,
        taglist_buttons,
        nil,
        wibarutil.list_update(beautiful.lightblue)
    )

-- Systray
-------------------------------------------------------------------------------
    local systray = wibox.layout.margin(wibox.widget.systray(), 0, 0, 5, 5)
    beautiful.systray_icon_spacing = 7

-- global title bar    ------ holgerschurig.de/en/awesome-4.0-global-titlebar/
-------------------------------------------------------------------------------
    s.mytitle = wibox.widget {
        markup = " ",
        align = "center",
        font = "FontAwesome Bold 10",
        widget = wibox.widget.textbox,
    }
    local function update_title_text(c)
        s = awful.screen.focused()
        if c == client.focus then
            if c.class then
                s.mytitle.text = c.class
            end
        end
    end
    client.connect_signal("focus", update_title_text)
    client.connect_signal("property::name", update_title_text)
    client.connect_signal("unfocus", function (c) s = awful.screen.focused() s.mytitle.markup = "" end)

    local wireless_widgets = net_widgets.indicator({indent = 0, widget = false, interface="wlp5s0",
        interfaces={"enp3s0"}})
-- Wibar
-------------------------------------------------------------------------------
    -- Create the wibar
    s.mywibox = awful.wibar({position = "top", screen = s, height = 25})

    s.titlebar_buttons = wibox.widget {
        homogeneous     = false,
        expand          = true,
        layout = wibox.layout.grid.horizontal
    }

--local vimawesome = require("vimawesome")
    -- add widgets to the wibar
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        { -- Left widgets
            wibarutil.rectangle(mylauncher, beautiful.lightblue, 4, 4),
            s.mytaglist,
            mpd.widget,
            s.mypromptbox,
            --vimawesome.sequence,
            --vimawesome.modename,
            layout = wibox.layout.fixed.horizontal,
        },
        { -- Middle widgets
            s.mytitle,
            layout = wibox.layout.align.horizontal,
        },
        { -- Right widgets
            systray,

            -- Wireless Widget
            wibarutil.separator(beautiful.bg_normal, beautiful.fg4, true),
            wibarutil.rectangle(wireless_widgets.textbox, beautiful.fg4, 2, 2),
            wibarutil.separator(beautiful.fg4, beautiful.bg1),
            wibarutil.rectangle(wireless_widgets.imagebox, beautiful.bg1, 4, 4, 4, 4),

            -- Audio Volume
            wibarutil.separator(beautiful.bg1, beautiful.fg4, true),
            wibarutil.rectangle(volume.text, beautiful.fg4, 2, 2),
            wibarutil.separator(beautiful.fg4, beautiful.bg1),
            wibarutil.rectangle(volume.img, beautiful.bg1, 4, 4, 4, 4),

            -- Battery Indicator
            wibarutil.separator(beautiful.bg1, beautiful.fg4, true),
            wibarutil.rectangle(battery.text, beautiful.fg4, 2, 2),
            wibarutil.separator(beautiful.fg4, beautiful.bg1),
            wibarutil.rectangle(battery.img, beautiful.bg1, 4, 4, 4 ,4),

            -- Clock / Layout
            wibarutil.separator(beautiful.bg1, beautiful.fg4, true),
            wibarutil.rectangle(mytextclock, beautiful.fg4, 2, 2),
            wibarutil.separator(beautiful.fg4, beautiful.bg1),
            wibarutil.rectangle(s.mylayoutbox,beautiful.bg1, 4, 4, 6, 6),

            -- Global Titlebar Buttons
            wibarutil.rectangle(s.titlebar_buttons, beautiful.bg1, 0, 4, 6, 6),
            layout = wibox.layout.fixed.horizontal,
        },
    }
end)
-- }}}

--------------------------------------------------------------------------------
-- {{{ Mouse bindings & Key bindings
--------------------------------------------------------------------------------

local globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
    {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
    {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
    {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
    {description = "go back", group = "tag"}),
    awful.key({ "Mod1",           }, "Tab",      revelation,
    {description = "show all clients on screen", group = "tag"}),
    awful.key({modkey             }, "Tab", function()
                revelation({curr_tag_only=true}) end,
    {description = "show all clients on current tag", group = "tag"}),
    awful.key({modkey             }, "a", function()
                local tags = awful.screen.focused().selected_tags
                awful.tag.viewnone(awful.screen.focused())

                local grabber = awful.keygrabber.run(function(_, _, event)
                    if event == "press" then
                        awful.tag.viewmore(tags)
                        awful.keygrabber.stop(grabber)
                    end
                end)
        end,
    {description = "hide all visible clients until keypress", group = "tag"}),
    awful.key({ modkey,           }, "j",
    function ()
        awful.client.focus.byidx( 1)
    end,
    {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
    function ()
        awful.client.focus.byidx(-1)
    end,
    {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({ coords = { x = 0, y = 0 } }) end,
    {description = "show main menu", group = "awesome"}),

-- Layout manipulation
-------------------------------------------------------------------------------
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
    {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
    {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
    {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
    {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
    {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey, "Control" }, "Tab",
    function ()
        awful.client.focus.history.previous()
        if client.focus then
            client.focus:raise()
        end
    end,
    {description = "go back", group = "client"}),

-- Standard program
-------------------------------------------------------------------------------
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
          {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey,  "Shift"  }, "Return", function() awful.spawn(terminal.." -e ranger") end,
          {description = "ranger", group = "launcher"}),
    awful.key({ modkey,           }, "p", function() awful.spawn.with_shell(
          "scrot 'Screenshot-%Y%m%d-%H%M%S.png' -e 'mv $f ~/Pictures/' && notify-send 'Screenshot taken.'") end,
          {description = "scrot", group = "launcher"}),
    awful.key({ modkey,           }, "q", function() awful.spawn("firefox") end,
          {description = "firefox", group = "launcher"}),
    awful.key({ modkey,           }, "l", function() awful.spawn("physlock -s") end,
          {description = "lock the screen", group = "launcher"}),
    awful.key({ modkey, "Shift"   }, "m", function() mpd.reconnect() end,
          {description = "mpd server reconnect", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
          {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
          {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey, "Mod1"    }, "l", function () awful.tag.incmwfact( 0.05) end,
          {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey, "Mod1"    }, "h", function () awful.tag.incmwfact(-0.05) end,
          {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Mod1"    }, "k", function () awful.client.incwfact( 0.05) end,
          {description = "increase client height factor", group = "layout"}),
    awful.key({ modkey, "Mod1"    }, "j", function () awful.client.incwfact(-0.05) end,
          {description = "decrease client height factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h", function () awful.tag.incnmaster( 1, nil, true) end,
          {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l", function () awful.tag.incnmaster(-1, nil, true) end,
          {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol( 1, nil, true) end,
          {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1, nil, true) end,
          {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1) end,
          {description = "select next layout", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1) end,
          {description = "select previous next", group = "layout"}),
    awful.key({ modkey,           }, "e", function ()
        awful.spawn(terminal.." -e " .. gears.filesystem.get_dir("config") .. "/ncmpcpp.sh",
            {tag=awful.screen.focused().tags[6]})
        mpd.reconnect()
    end,
          {description = "ncmpcpp", group = "launcher"}),
    awful.key({ modkey, "Control" }, "n",
    function ()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            client.focus = c
            c:raise()
        end
    end,
          {description = "restore minimized", group = "client"}),

-- Prompt
-------------------------------------------------------------------------------
    awful.key({ modkey          }, "r", function () awful.spawn("rofi -modi drun,run -show drun -theme gruvbox") end,
          {description = "rofi launcher", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "r", function ()
            awful.spawn.with_shell("DRI_PRIME=1 rofi -modi drun,run -show drun -theme gruvbox")
        end,
          {description = "rofi launcher on dGPU", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "x",
    function ()
        awful.prompt.run {
            prompt       = "Run Lua code: ",
            textbox      = awful.screen.focused().mypromptbox.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval"
        }
    end,
          {description = "lua execute prompt", group = "awesome"}),

-- Lenovo Thinkpad E480 function keys
-------------------------------------------------------------------------------
    awful.key({}, "#121",
    function (_) awful.spawn("amixer -D pulse set Master +1 toggle") end),
    awful.key({}, "#122",
    function (_) awful.spawn("amixer -D pulse sset Master 5%-") end),
    awful.key({}, "#123",
    function (_) awful.spawn("amixer -D pulse sset Master 5%+") end),
    awful.key({}, "#232",
    function (_) awful.spawn("xbacklight -dec 10") end),
    awful.key({}, "#233",
    function (_) awful.spawn("xbacklight -inc 10") end),
    awful.key({}, "#198",
    function (_) awful.spawn("amixer set Capture toggle") end),
    awful.key({}, "#179",
    function (_) awful.spawn(editor_cmd .. " " .. awesome.conffile) end),
    awful.key({}, "#235",
    function (_) awful.spawn.with_shell(gears.filesystem.get_dir("config") .. "/monitor.sh") end)
)

-- Client & Tag Manipulation
-------------------------------------------------------------------------------
local clientkeys = gears.table.join(
awful.key({ modkey    }, "f",
function (c)
    c.fullscreen = not c.fullscreen
    c:raise()
end,
      {description = "toggle fullscreen", group = "client"}),
awful.key({ modkey,   "Shift" }, "c",      function (c) c:kill() end,
      {description = "close", group = "client"}),
awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle,
      {description = "toggle floating", group = "client"}),
awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
      {description = "move to master", group = "client"}),
awful.key({ modkey,           }, "o",      function (c) c:move_to_screen() end,
      {description = "move to screen", group = "client"}),
awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop end,
      {description = "toggle keep on top", group = "client"}),
awful.key({ modkey,           }, "z",      function (c) c.sticky = not c.sticky end,
      {description = "toggle sticky", group = "client"}),
awful.key({ modkey,           }, "n", function (c) c.minimized = true end,
      {description = "minimize", group = "client"}),
awful.key({ modkey,           }, "m",
function (c)
    c.maximized = not c.maximized
    c.maximized_vertical = false
    c.maximized_horizontal = false
    c:raise()
end ,
      {description = "(un)maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
    -- View tag only.
    awful.key({ modkey }, "#" .. i + 9,
    function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
            tag:view_only()
        end
    end,
    {description = "view tag #"..i, group = "tag"}),
    -- Toggle tag display.
    awful.key({ modkey, "Control" }, "#" .. i + 9,
    function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
            awful.tag.viewtoggle(tag)
        end
    end,
    {description = "toggle tag #" .. i, group = "tag"}),
    -- Move client to tag.
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
    function ()
        if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then
                client.focus:move_to_tag(tag)
            end
        end
    end,
    {description = "move focused client to tag #"..i, group = "tag"}),
    -- Toggle tag on focused client.
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
    function ()
        if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then
                client.focus:toggle_tag(tag)
            end
        end
    end,
    {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

local clientbuttons = gears.table.join(
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey }, 1, awful.mouse.client.move),
awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
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
    keys = clientkeys,
    buttons = clientbuttons,
    screen = awful.screen.preferred,
    placement = awful.placement.no_overlap+awful.placement.no_offscreen,
    size_hints_honor = false,
    titlebars_enabled = true
    }
       },

    -- Firefox always on tag 1
    { rule = { class = "Firefox" },
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
    local maximizedbutton = wibox.container.margin(awful.titlebar.widget.maximizedbutton(c), 4, 4)
    local ontopbutton     = wibox.container.margin(awful.titlebar.widget.ontopbutton(c), 4, 4)
    local stickybutton    = wibox.container.margin(awful.titlebar.widget.stickybutton(c), 4, 4)
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
