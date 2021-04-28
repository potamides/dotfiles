local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local mpc = require("widgets.mpd.mpc")
local stream = require("widgets.mpd.stream")
local escape = require("lgi").GLib.markup_escape_text

local mpd = {}
local stream_instance

local function update_widget(title, artist, state)
  local text = ""
  if state == "play" and title then
    text = artist and artist .. " - " .. title or title
    mpd.widget:set_bg(beautiful.bg_focus)
  else
    mpd.widget:set_bg(beautiful.bg_normal)
  end
  mpd.text:set_markup(string.format("<span color=%q><b>%s</b></span>",
    beautiful.fg_normal, escape(text, string.len(text))))
end

local function update_stream(host, port, socket, old_state, new_state)
  if new_state ~= old_state then
    if new_state == "play" then
      if not stream_instance then
        stream_instance = stream.new(host, port, socket)
      end
      stream_instance:play()
    elseif stream_instance then
      stream_instance:pause()
    end
  end
end

local function error_handler()
  -- Try a reconnect soon-ish
  gears.timer.start_new(60, function()
    mpd.connection:send("ping")
  end)
end

function mpd.toggle()
  mpd.connection:toggle_play()
end

function mpd.init(args)
  args = args or {}

  if args.widget_template then
    mpd.widget = wibox.widget(args.widget_template)
    mpd.text = mpd.widget:get_children_by_id("text_role")[1]
  else
    mpd.text = wibox.widget.textbox()
    mpd.widget = wibox.container.background(mpd.text)
  end

  local state = "stop"
  mpd.connection = mpc.new(args.host, args.port, args.password, error_handler,
    "status", function(_, result)
      update_stream(args.host, args.stream_port, args.socket, state, result.state)
      state = result.state
    end,
    "currentsong", function(_, result)
      update_widget(result.title, result.artist, state)
  end)
end

return mpd
