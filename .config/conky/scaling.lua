-- This script adds basic scaling support to conky. It uses a new table
-- "conky.sizes", which should have vertical resolutions (e.g. 1080) as keys
-- and tables of sizes as values. Sizes can be specified as key, value pairs
-- which can then be used in the config through the "<key>" placeholder (this
-- is configurable). This script then chooses the correct sizes depending on
-- the resolution of the screen. If the resolution is not supported (e.g. not
-- in the "conky.sizes" table), the autoscale algorithm is used which
-- calculates the sizes to use from the closest specified resolution. For
-- reference the primary screen is used. "Xrandr" must be installed for this to
-- work as intended.

local scaling = {
  format = "<%s>",
  resolution = tonumber(io.popen("xrandr"):read("*a"):match("primary %d+x(%d+)")) or 1080
}

function scaling:autoscale()
  local fallback, autosizes = math.huge, {}

  for resolution, _ in pairs(conky.sizes) do
    if math.abs(self.resolution - resolution) < math.abs(self.resolution - fallback) then
      fallback = resolution
    end
  end

  for id, value in pairs(conky.sizes[fallback]) do
    local scaled = (self.resolution * value) / fallback
    autosizes[id] = math.floor(scaled + 0.5)
  end

  return autosizes
end

function scaling:apply(str)
  for id, value in pairs(conky.sizes[self.resolution] or self:autoscale()) do
    str = string.gsub(str, string.format(self.format, id), value)
  end

  return tonumber(str) or str
end

function scaling:scale(item)
  if conky.sizes then
    if type(item) == "table" then
      for index, value in pairs(item) do
        if type(value) == "string" then
          item[index] = self:apply(value)
        end
      end
    elseif type(item) == "string" then
      item = self:apply(item)
    end
  end
  return item
end

_G.conky = setmetatable({}, {__newindex = function(_, key, value) rawset(conky, key, scaling:scale(value)) end})
