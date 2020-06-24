local Gst = require("lgi").Gst

local stream = {}

function stream.new(host, port)
	host = host or os.getenv("MPD_HOST") or "localhost"
	port = port or os.getenv("MPD_STREAM_PORT") or 8000

  local link = string.format("http://%s:%s", host, port)
  local pipeline = Gst.parse_launch("playbin uri=" .. link)

	local self = setmetatable({_pipeline = pipeline}, {__index = stream})
	return self
end

function stream:play()
  -- flush buffers when mpd changes song to start new song immediately
  Gst.Event.new_flush_start()
  Gst.Element.set_state(self._pipeline, Gst.State.PLAYING)
end

function stream:pause()
  -- flush buffers and reject further data
  Gst.Element.set_state(self._pipeline, Gst.State.READY)
end

function stream:stop()
  Gst.Element.set_state(self._pipeline, Gst.State.NULL)
end

return stream
