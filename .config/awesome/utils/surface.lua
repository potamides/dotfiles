local gsurface = require("gears.surface")
local cairo = require("lgi").cairo

local surface = {}

-- Crop a surface to size {width, height}. When reverse is true, the anchor
-- point is in lower right corner instead of upper left.
function surface.crop(s, width, height, reverse)
  s = gsurface.load(s)
  local w, h = gsurface.get_size(s)
  local result = s:create_similar(s.content, width, height)
  local cr = cairo.Context(result)

  if reverse then
    cr:set_source_surface(s, width - w, height - h)
  else
    cr:set_source_surface(s, 0, 0)
  end

  cr.operator = cairo.Operator.SOURCE
  cr:paint()

  return result
end

return surface
