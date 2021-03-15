local gears = require("gears")
local beautiful = require("beautiful")
local wibarutil = require("utils.wibar")
local wibox = require("wibox")
local mpc = require("widgets.mpd.mpc")
local stream = require("widgets.mpd.stream")
local escape = require("lgi").GLib.markup_escape_text

local mpd_widget = wibox.widget.textbox()
local mpd_container = wibarutil.create_parallelogram({
    mpd_widget,
    max_size = beautiful.xresources.apply_dpi(200),
    speed = 70,
    step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
    layout = wibox.container.scroll.horizontal,
  },
  wibarutil.left_parallelogram, beautiful.bg_normal, beautiful.small_gap)

local function update_widget(title, artist, state)
  local text = ""
  if state == "play" and title then
    text = artist and artist .. " - " .. title or title
    mpd_container:set_bg(gears.color(beautiful.bg1))
  else
    mpd_container:set_bg(gears.color(beautiful.bg_normal))
  end
  mpd_widget:set_markup(string.format("<span color=%q><b>%s</b></span>",
    beautiful.fg_normal, escape(text, string.len(text))))
end

local stream_instance
local function update_stream(old_state, new_state)
  if new_state ~= old_state then
    if new_state == "play" then
      if not stream_instance then
        stream_instance = stream.new()
      end
      stream_instance:play()
    elseif stream_instance then
      stream_instance:pause()
    end
  end
end

local connection
local function error_handler()
  -- Try a reconnect soon-ish
  gears.timer.start_new(60, function()
    connection:send("ping")
  end)
end

local state = "stop"
connection = mpc.new(nil, nil, nil, error_handler,
  "status", function(_, result)
    update_stream(state, result.state)
    state = result.state
  end,
  "currentsong", function(_, result)
    update_widget(result.title, result.artist, state)
end)

local mpd = {widget = mpd_container, toggle = function() connection:toggle_play() end}
return mpd
