local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local wibarutil = require("utils.wibar")
local wibox = require("wibox")
local mpc = require("status-widgets.mpd-widget.mpc")
local stream = require("status-widgets.mpd-widget.stream")
local escape = require("lgi").GLib.markup_escape_text

local mpd_widget = wibox.widget.textbox()
local mpd_container = wibarutil.create_parallelogram({
    mpd_widget,
    max_size = 200,
    speed = 70,
    step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
    layout = wibox.container.scroll.horizontal,
  },
  wibarutil.left_parallelogram, beautiful.bg_normal, beautiful.small_gap)

local state, title, artist = "stop"
local function update_widget()
    local text = ""
    if state == "play" and title then
        if artist then text = artist .. " - " end
        text = text .. tostring(title)
        mpd_container:set_bg(gears.color(beautiful.bg1))
    else
        mpd_container:set_bg(gears.color(beautiful.bg_normal))
    end
    mpd_widget:set_markup(string.format("<span color=%q><b>%s</b></span>",
        beautiful.fg_normal, escape(text, string.len(text))))
end

local stream_instance
local function update_stream()
  if state == "play" then
    if not stream_instance then
      stream_instance = stream.new()
    end
    stream_instance:play()
  elseif stream_instance then
    stream_instance:pause()
  end
end

local connection
local function error_handler()
  -- Try a reconnect soon-ish
  gears.timer.start_new(60, function()
    connection:send("ping")
  end)
end

local should_update = true
connection = mpc.new(nil, nil, nil, error_handler,
  "status", function(_, result)
    state = result.state
    -- duration is nil on live streams. Since many live streams are continuous,
    -- don't hit play again when a song changes to avoid interruptions
    if state == "play" and (result.duration or should_update) then
      update_stream()
      should_update = result.duration ~= nil
    elseif state ~= "play" then
      update_stream()
      should_update = true
    end
  end,
  "currentsong", function(_, result)
    title = result.title
    artist = result.artist
    update_widget()
  end)

mpd_container:buttons(awful.button({ }, 1,
	function()
    if state == "play" and title then
      mpd_widget:set_markup(string.format("<span color=%q><b>%s</b></span>",
      beautiful.lightaqua, mpd_widget.text))

      -- save titles of intresting songs for later, useful for radio streams
      local Playlist=io.open(os.getenv("HOME") .. "/Documents/Playlist", "a+")
      if not string.find(Playlist:read("*a"), title, 1, true) then
        Playlist:write(title .. "\n")
      end
      Playlist:close()
    end
  end,
  function()
    mpd_widget:set_markup(string.format("<span color=%q><b>%s</b></span>",
      beautiful.fg_normal, mpd_widget.text))
  end))

local mpd = {widget = mpd_container, toggle = function() connection:toggle_play() end}
return mpd
