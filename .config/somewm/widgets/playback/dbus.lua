local gtable = require("gears.table")

local musicbus = {
  callbacks = {}
}

-- Connect to dbus and wait for invocations of
-- org.awesomewm.awful.Playback.Status. Registered callbacks are then called
-- with the transmitted data. Primarily this allows external processes to send
-- currently played music metadata to the awesome music widget in a simple
-- manner.
dbus.connect_signal("org.awesomewm.awful.Playback", function(data, status)
  if data.member == "Status" then
    for _, callback in ipairs(musicbus.callbacks) do
      callback(status)
    end
  end
end)

-- register a new callback
function musicbus.connect(callback)
  table.insert(musicbus.callbacks, callback)
end

-- remove an existing callback
function musicbus.disconnect(callback)
  table.remove(musicbus.callbacks, gtable.hasitem(musicbus.callbacks, callback))
end

return musicbus
