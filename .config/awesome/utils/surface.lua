local gsurface = require("gears.surface")
local cairo = require("lgi").cairo

local surface = {}

-- Crops a surface from starting point (xstart,ystart) to (xstop, ystop).
function surface.crop(s, xstart, ystart, xstop, ystop)
  s = gsurface.load(s)
  local result = s:create_similar(s.content, xstop - xstart, ystop - ystart)
  local cr = cairo.Context(result)

  cr:set_source_surface(s, -xstart, -ystart)
  cr.operator = cairo.Operator.SOURCE
  cr:paint()

  return result
end

return surface
