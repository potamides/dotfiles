local timer = require("gears.timer")
local new_for_path = require("lgi").Gio.File.new_for_path

local monitor = {}

--[[
-- Monitor a file for changes, either with events or through polling.
-- The callback is called with the concatenated content of all files.
-- Syntax:
--   monitor.new(<file>..., <callback>, [<timeout>], [<use-events>])
--]]
function monitor.new(...)
  local args, self = {...}, setmetatable({}, {__index = monitor})
  local use_events, rate_limit

  use_events = type(args[#args]) == "boolean" and table.remove(args) or false
  rate_limit = type(args[#args]) == "number" and table.remove(args) or 1
  self._callback = table.remove(args)
  self._contents = {len = #args}
  self._gmons = {}

  if use_events then
    for idx, file in ipairs(args) do
      local gfile = new_for_path(file)
      local gmon = gfile:monitor({})
      gmon.on_changed = self:_create_event_callback(idx)
      gmon:set_rate_limit(rate_limit * 1000)
      self:_read_async(gfile, idx)
      table.insert(self._gmons, gmon)
    end
  else
    self._timer = timer{
      timeout = rate_limit,
      autostart = true,
      call_now = true,
      callback = self:_create_poll_callback(args)}
  end

  return self
end

function monitor:_all_reads_completed()
  local count = 0
  for _ in ipairs(self._contents) do
    count = count + 1
  end
  return count == self._contents.len
end

function monitor:_read_async(file, index)
  file:load_contents_async(nil, function(_, result)
    local content = file:load_contents_finish(result)
    if content then
      self._contents[index] = content
      if self:_all_reads_completed() then
        self._callback(table.concat(self._contents), "\n")
        for i = 1, #self._contents do
          self._contents[i] = nil
        end
      end
    end
  end)
end

function monitor:_create_poll_callback(files)
  local gfiles = {}
  for _, file in ipairs(files) do
    table.insert(gfiles, new_for_path(file))
  end

  return function()
    for idx, gfile in ipairs(gfiles) do
      self:_read_async(gfile, idx)
    end
  end
end

function monitor:_create_event_callback(index)
  return function(_, file, _, event)
    if event == "CHANGED" then
      self:_read_async(file, index)
    end
  end
end

return setmetatable(monitor, {__call = function(_, ...) return monitor.new(...) end})
