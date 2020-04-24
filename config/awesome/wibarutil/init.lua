local beautiful = require("beautiful")
local wibox     = require("wibox")


local function right_parallelogram(cr, width, height, degree)
    degree = degree or 10
    cr:move_to(degree, 0)
    cr:line_to(width, 0)
    cr:line_to(width - degree, height)
    cr:line_to(0, height)
    cr:close_path()
end

local function left_parallelogram(cr, width, height, degree)
    degree = degree or 10
    cr:move_to(0, 0)
    cr:line_to(width - degree, 0)
    cr:line_to(width, height)
    cr:line_to(degree, height)
    cr:close_path()
end

local function rightmost_parallelogram(cr, width, height, degree)
    degree = degree or 10
    cr:move_to(degree, 0)
    cr:line_to(width, 0)
    cr:line_to(width, height)
    cr:line_to(0, height)
    cr:close_path()
end

local function leftmost_parallelogram(cr, width, height, degree)
    degree = degree or 10
    cr:move_to(0, 0)
    cr:line_to(width - degree, 0)
    cr:line_to(width, height)
    cr:line_to(0, height)
    cr:close_path()
end

local function create_parallelogram(widget, parallelogram, color, margin)
    return wibox.widget {
        {
            widget,
            top = margin or beautiful.small_gap,
            bottom = margin or beautiful.small_gap,
            left  = parallelogram == leftmost_parallelogram and beautiful.gap or beautiful.big_gap,
            right = parallelogram == rightmost_parallelogram and beautiful.gap or beautiful.big_gap,
            widget = wibox.container.margin
        },
        shape = parallelogram,
        bg = color,
        widget = wibox.container.background
    }
end


local function compose_parallelogram(left_widget, right_widget, left_shape, right_shape, margin)
    return wibox.widget {
        {
            {
                left_widget,
                left = left_shape == right_parallelogram and beautiful.big_gap or beautiful.gap,
                right = beautiful.big_gap,
                widget = wibox.container.margin
            },
            shape = left_shape,
            bg = beautiful.fg4,
            widget = wibox.container.background
        },
        {
            {
                {
                    right_widget,
                    top = margin or beautiful.small_gap,
                    bottom = margin or beautiful.small_gap,
                    left = beautiful.big_gap,
                    right = right_shape == right_parallelogram and beautiful.big_gap or beautiful.gap,
                    widget = wibox.container.margin
                },
                widget = wibox.container.place
            },
            shape = right_shape,
            bg = beautiful.bg1,
            widget = wibox.container.background
        },
        spacing = 2 * beautiful.negative_gap,
        layout = wibox.layout.fixed.horizontal
    }
end


local wibarutil = {
  left_parallelogram = left_parallelogram,
  right_parallelogram = right_parallelogram,
  leftmost_parallelogram = leftmost_parallelogram,
  rightmost_parallelogram = rightmost_parallelogram,
  compose_parallelogram = compose_parallelogram,
  create_parallelogram = create_parallelogram,
 }

return wibarutil
