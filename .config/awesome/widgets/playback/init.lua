local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local mpd = require("widgets.playback.mpd")
local escape = require("lgi").GLib.markup_escape_text
local musicbus = require("widgets.playback.dbus")

local playback = {mpd = {}}

local function update_text(title, artist, state)
  local text = ""
  if state == "play" and title then
    text = artist and artist .. " - " .. title or title
  end
  playback.text:set_markup(beautiful.widget_markup:format(beautiful.fg_normal, escape(text, text:len())))
end

local function update_mpd_stream(host, port, socket, old_state, new_state)
  if new_state ~= old_state then
    if new_state == "play" then
      if not playback.mpd.stream then
        playback.mpd.stream = mpd.stream.new(host, port, socket)
      end
      playback.mpd.stream:play()
    elseif playback.mpd.stream then
      playback.mpd.stream:pause()
    end
  end
end

local function mpd_error_handler()
  -- Try a reconnect soon-ish
  gears.timer.start_new(60, function()
    playback.mpd.connection:send("ping")
  end)
end

function playback.mpd.toggle()
  playback.mpd.connection:toggle_play()
end

-- Display song information obtained via dbus or from mpd (see dbus.lua and
-- mpd/client.lua in a widget. Also connect to mpd streaming daemon and play
-- back music using mpv (see mpd/stream.lua).
function playback.init(args)
  playback.text, args = wibox.widget.textbox(), args or {}

  local mpd_state = "stop"
  playback.mpd.connection = mpd.client.new(args.host, args.port, args.password, mpd_error_handler,
    "status", function(_, result)
      update_mpd_stream(args.host, args.stream_port, args.socket, mpd_state, result.state)
      mpd_state = result.state
    end,
    "currentsong", function(_, result)
      update_text(result.title, result.artist, mpd_state)
  end)

  musicbus.connect(function(result)
    -- mpd connection has precedence over dbus
    if mpd_state ~= "play" then
      update_text(result.title, result.artist, result.state)
    end
  end)
end

return playback
