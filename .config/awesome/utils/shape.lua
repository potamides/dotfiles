local gshape = require("gears.shape")
local beautiful = require("beautiful")
local shape = {parallelogram = {}, rightangled = {}}

function shape.parallelogram.right(cr, width, height, degree)
  degree = degree or beautiful.pgram_slope
  cr:move_to(degree, 0)
  cr:line_to(width, 0)
  cr:line_to(width - degree, height)
  cr:line_to(0, height)
  cr:close_path()
end

function shape.rightangled.right(cr, width, height, degree)
  degree = degree or beautiful.pgram_slope
  cr:move_to(degree, 0)
  cr:line_to(width, 0)
  cr:line_to(width, height)
  cr:line_to(0, height)
  cr:close_path()
end

-- mirror the shapes horizontally
for _, trapezoids in pairs(shape) do
  function trapezoids.left(cr, width, ...)
    gshape.transform(trapezoids.right):translate(width, 0):scale(-1, 1)(cr, width, ...)
  end
end

-- and the rightangled ones also vertically
for name, trapezoid in pairs(shape.rightangled) do
  shape.rightangled[name .. "_mirrored"] = function(cr, width, height, ...)
    gshape.transform(trapezoid):translate(0, height):scale(1, -1)(cr, width, height, ...)
  end
end

return shape
