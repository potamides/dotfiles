-------------------------------------------------------------------------------
--   When a song is played with mpv send its information to awesome wm via   --
--                dbus to display it in the playback widget.                 --
-------------------------------------------------------------------------------
local mp = require("mp")
local utils = require("mp.utils")
-- if lgi is available use glib bindings for dbus
local lgi_installed, lgi = pcall(require, "lgi")

local playback = {
  info = {id = tostring(utils.getpid())},
  -- same states as used by mpd
  states = {
    PLAY  = "play",
    PAUSE = "pause",
    STOP  = "stop"
  }
}

function playback.dbus_update()
  local path, dest = "/", "org.awesomewm.awful"
  local interface, member = dest .. ".Playback", "Status"

  -- wait until at least state and title are known
  if playback.info.state and playback.info.title then
    if lgi_installed then
      if not playback.bus then
        playback.bus = lgi.Gio.bus_get_sync(lgi.Gio.BusType.SESSION)
      end
      playback.bus:emit_signal(dest, path, interface, member, lgi.GLib.Variant("(a{ss})", {playback.info}))
    else
        local info = "dict:string:string:"
        for key, value in pairs(playback.info) do
          info = info .. string.format("%s,%s,", key, value:gsub(",", ""))
        end
        mp.commandv("run", "dbus-send", "--dest=" .. dest, path, interface .. "." .. member, info)
    end
  end
end

function playback.update_title(_, metadata)
  if metadata then
    playback.info.title = metadata.title or metadata["icy-title"]
    playback.info.artist = metadata.artist
    playback.dbus_update()
  end
end

function playback.update_state(event, value)
  if event.event == "shutdown" then
    playback.info.state = playback.states.STOP
  elseif event == "pause" then
    playback.info.state = value and playback.states.PAUSE or playback.states.PLAY
  end
  playback.dbus_update()
end

mp.observe_property("metadata", "native", playback.update_title)
mp.observe_property("pause", "bool", playback.update_state)
mp.register_event("shutdown", playback.update_state)
