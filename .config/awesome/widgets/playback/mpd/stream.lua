local awful = require("awful")
local gears = require("gears")
local lgi = require("lgi")
local GLib = lgi.GLib
local Gio = lgi.Gio

local stream = {}

-- Connect to the built-in HTTP streaming daemon of mpd and play music via mpv
function stream.new(host, port, socket)
  host   = host or os.getenv("MPD_HOST") or "localhost"
  port   = port or os.getenv("MPD_STREAM_PORT") or 8000
  socket = socket or "/tmp/mpv-mpd-stream-socket"

  local link = string.format("http://%s:%s", host, port)
  local self = setmetatable({
    _link   = link,
    _socket = socket,
    _spawned   = false,
    _connected = false},
    {__index = stream})

    self._timer = gears.timer{
      timeout = 600,
      single_shot = true,
      callback = function() self:close() end}

  return self
end

function stream:_connect()
  if self._connected then
    return true
  end

  -- connect to mpv instance
  local client  = Gio.SocketClient()
  local address = Gio.UnixSocketAddress.new(self._socket)
  local conn    = client:connect(address)

  if not conn then
    return false
  end

  self._connected = true
  self._conn      = conn
  self._output    = conn:get_output_stream()
  self._input     = Gio.DataInputStream.new(conn:get_input_stream())

  local read_response
  read_response = function()
    -- read response to prevent the unix socket from blocking because of full buffer
    self._input:read_line_async(GLib.PRIORITY_DEFAULT, nil, function(obj, res)
      obj:read_line_finish(res)
      if not self._conn:is_closed() then
        read_response()
      end
    end)
  end
  read_response()

  return true
end

function stream:_spawn_mpv()
  local cmd = "mpv --load-scripts=no --idle=yes --no-terminal --cache-pause-initial=yes --input-ipc-server=%s %s"
  awful.spawn(cmd:format(self._socket, self._link), false)
  self._spawned = true
end

function stream:play()
  self._timer:stop()
  if not self._connected and not self:_connect() and not self._spawned then
    -- if we can't connect to mpv, we have to spawn it
    self:_spawn_mpv()
  else
    self._output:write_all('{ "command": ["playlist-play-index", 0] }\n')
  end
end

function stream:pause()
  if not self._connected and not self:_connect() then
    return
  end
  -- flush buffers and reject further data
  self._output:write_all('{ "command": ["stop", "keep-playlist"] }\n')
  -- close mpv after 10 minutes of inactivity
  self._timer:again()
end

function stream:close()
  if not self._connected and not self:_connect() then
    return
  end
  self._output:write_all('{ "command": ["quit"] }\n')
  self._conn:close()
  self._spawned   = false
  self._connected = false
end

return stream
