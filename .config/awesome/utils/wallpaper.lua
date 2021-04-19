local gwallpaper = require("gears.wallpaper")
local gsurface = require("gears.surface")
local gdebug = require("gears.debug")
local cairo = require("lgi").cairo

local wallpaper = {}

-- Scales surface to width or height of screen and then repeats along other
-- axis. The repeated axis can be chosen with the "direction" parameter and can
-- take the values "horizontal" or "vertical".
function wallpaper.repeated(original_surf, s, direction, offset)
  direction = direction or "horizontal"
  local geom, cr = gwallpaper.prepare_context(s)
  local surf = gsurface.load_uncached(original_surf)

  if offset then
    cr:translate(offset.x, offset.y)
  end

  -- Now fit the surface
  local w, h = gsurface.get_size(surf)
  local scale = direction == "horizontal" and geom.height / h or geom.width / w
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
