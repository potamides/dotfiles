local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local wibarutil = require("wibarutil")
local wibox = require("wibox")
local mpc = require("mpd.mpc")

local mpd_widget = wibox.widget.textbox()
local mpd_container = wibarutil.create_parallelogram({
    mpd_widget,
    max_size = 200,
    speed = 70,
    step_function = wibox.container.scroll.step_functions .waiting_nonlinear_back_and_forth,
    layout = wibox.container.scroll.horizontal,
  },
  wibarutil.left_parallelogram, beautiful.bg_normal)

local state, title, artist = "stop"
local function update_widget()
    local text = ""
    if state ~= "pause" and state ~= "stop" and title then
        if artist then text = artist .. " - " end
        text = text .. tostring(title)
        mpd_container:set_bg(gears.color(beautiful.bg1))
    else
        mpd_container:set_bg(gears.color(beautiful.bg_normal))
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

mpd_container:buttons(awful.button({ }, 1,
	function()
        mpd_widget:set_markup(string.format("<span color=%q><b>%s</b></span>",
        beautiful.lightaqua, mpd_widget.text))

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

local mpd = {widget = mpd_container, reconnect = reconnect}
return mpd
