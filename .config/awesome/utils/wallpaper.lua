local gwallpaper = require("gears.wallpaper")
local gsurface = require("gears.surface")
local gdebug = require("gears.debug")
local cairo = require("lgi").cairo

local wallpaper = {}

-- Scales surface to width or height of screen and then repeats along other
-- axis. By default scales horizontally and repeats vertically, which can be
-- reversed by setting the "vertical" parameter to true.
function wallpaper.repeated(original_surf, s, vertical, offset)
  local geom, cr = gwallpaper.prepare_context(s)
  local surf = gsurface.load_uncached(original_surf)

  if offset then
    cr:translate(offset.x, offset.y)
  end

  -- Now fit the surface
  local w, h = gsurface.get_size(surf)
  local scale = vertical and geom.width / w or geom.height / h
  cr:translate((geom.width - (w * scale)), 0)
  cr:scale(scale, scale)

  local pattern = cairo.Pattern.create_for_surface(surf)
  pattern.filter = cairo.Filter.NEAREST
  pattern.extend = cairo.Extend.REPEAT
  cr.source = pattern
  cr.operator = cairo.Operator.SOURCE
  cr:paint()

  if surf ~= original_surf then
    surf:finish()
  end
  if cr.status ~= "SUCCESS" then
    gdebug.print_warning("Cairo context entered error state: " .. cr.status)
  end
end

return wallpaper
