local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local wibarutil = require("wibarutil")
local wibox = require("wibox")
local mpc = require("mpd.mpc")

local mpd_widget = wibox.widget.textbox()
local mpd_scroll_widget =
    wibox.widget {
       layout = wibox.container.scroll.horizontal,
       max_size = 200,
       step_function = wibox.container.scroll.step_functions
                       .waiting_nonlinear_back_and_forth,
       speed = 70,
       mpd_widget
    }
local mpd_container = wibarutil.rectangle(mpd_scroll_widget, beautiful.bg_normal, 4, 4)
local mpd_separator = wibarutil.separator(beautiful.bg_normal, beautiful.bg_normal, false, true)
local final_mpd_widget =
    wibox.widget {
            mpd_container,
            mpd_separator,
            forced_num_cols = 2,
            forced_num_rows = 1,
            expand          = true,
            homogeneous     = false,
            layout          = wibox.layout.grid.horizontal
    }

local state, title, artist = "stop"
local function update_widget()
    local text, left_sep = ""
    if state ~= "pause" and state ~= "stop" and title then
        if artist then text = artist .. " - " end
        text = text .. tostring(title)
        wibarutil.set_last_separator_color(beautiful.bg1)
        mpd_container:set_bg(gears.color(beautiful.bg1))
        left_sep = mpd_separator:get_children_by_id("left")[1]
        left_sep:set_bg(gears.color(beautiful.bg1))
        final_mpd_widget.visible = true
    else
        wibarutil.set_last_separator_color(beautiful.bg_normal)
        mpd_container:set_bg(gears.color(beautiful.bg_normal))
        left_sep = mpd_separator:get_children_by_id("left")[1]
        left_sep:set_bg(gears.color(beautiful.bg_normal))
        final_mpd_widget.visible = false
    end
    mpd_widget:set_markup(string.format("<span color=%q><b>%s</b></span>",
        beautiful.fg_normal, text))
end


local connection = mpc.new(nil, nil, nil, nil,
    "status", function(_, result)
        state = result.state
    end,
    "currentsong", function(_, result)
        title = result.title
        artist = result.artist
        update_widget()
    end)

local function reconnect()
    gears.timer.start_new(10, function()
        connection:send("ping")
    end)
end

mpd_scroll_widget:buttons(awful.button({ }, 1,
	function()
        mpd_widget:set_markup(string.format("<span color=%q><b>%s</b></span>",
        beautiful.lightblue, mpd_widget.text))

        local Playlist=io.open(os.getenv("HOME") .. "/Documents/Playlist", "a+")
        if not string.find(Playlist:read("*a"), title, 1, true)
            then Playlist:write(title .. "\n")
        end
        Playlist:close()
    end,
    function()
        mpd_widget:set_markup(string.format("<span color=%q><b>%s</b></span>",
            beautiful.fg_normal, mpd_widget.text))
    end))

local mpd = {widget = final_mpd_widget, reconnect = reconnect}
return mpd
