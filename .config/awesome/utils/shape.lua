local shape = {parallelogram = {}, rightangled = {}}

function shape.parallelogram.right(cr, width, height, degree)
  degree = degree or 10
  cr:move_to(degree, 0)
  cr:line_to(width, 0)
  cr:line_to(width - degree, height)
  cr:line_to(0, height)
  cr:close_path()
end

function shape.parallelogram.left(cr, width, height, degree)
  degree = degree or 10
  cr:move_to(0, 0)
  cr:line_to(width - degree, 0)
  cr:line_to(width, height)
  cr:line_to(degree, height)
  cr:close_path()
end

function shape.rightangled.right(cr, width, height, degree)
  degree = degree or 10
  cr:move_to(degree, 0)
  cr:line_to(width, 0)
  cr:line_to(width, height)
  cr:line_to(0, height)
  cr:close_path()
end

function shape.rightangled.left(cr, width, height, degree)
  degree = degree or 10
  cr:move_to(0, 0)
  cr:line_to(width - degree, 0)
  cr:line_to(width, height)
  cr:line_to(0, height)
  cr:close_path()
end

return shape
