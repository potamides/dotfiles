-- This library adds basic scaling support to conky. It uses a new table
-- "conky.sizes", which should have vertical resolutios (e.g. 1080) as keys and
-- a table of sizes as values. These sizes can be used in the config through
-- the "<sizeN>" placeholder (where N is the index in the table). This library
-- then choses the correct sizes depending on the resolution of the screen. If
-- the resolution is not supported (not in the "conky.sizes" table), the
-- autoscale algorithm is used. For reference the primary screen is used.
-- "Xrandr" must be installed for this to work.

local scaling = {
  resolution = tonumber(io.popen("xrandr"):read("*a"):match("primary %d+x(%d+)")) or 1080
}

function scaling.autoscale(num)
  local fallback = math.maxinteger
  for resolution, _ in pairs(conky.sizes) do
    if math.abs(scaling.resolution - resolution) < math.abs(scaling.resolution - fallback) then
      fallback = resolution
    end
  end
  local scaled = (scaling.resolution * conky.sizes[fallback][num]) / fallback
  return scaled % 2 >= 0.5 and math.ceil(scaled) or math.floor(scaled)
end

function scaling.apply(str)
  local item = string.gsub(str, "<size(%d+)>", function(num)
    num = tonumber(num)
    return conky.sizes[scaling.resolution] and conky.sizes[scaling.resolution][num] or scaling.autoscale(num)
  end)
  return tonumber(item) or item
end

function scaling.scale(item)
  if conky.sizes then
    if type(item) == "table" then
      for index, value in pairs(item) do
        if type(value) == "string" then
          item[index] = scaling.apply(value)
        end
      end
    elseif type(item) == "string" then
      item = scaling.apply(item)
    end
  end
  return item
end

conky = setmetatable({}, {__newindex = function(_, key, value) rawset(conky, key, scaling.scale(value)) end})
