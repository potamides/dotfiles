local beautiful = require("beautiful")
local wibox     = require("wibox")

local wibar = {}

function wibar.right_parallelogram(cr, width, height, degree)
    degree = degree or 10
    cr:move_to(degree, 0)
    cr:line_to(width, 0)
    cr:line_to(width - degree, height)
    cr:line_to(0, height)
    cr:close_path()
end

function wibar.left_parallelogram(cr, width, height, degree)
    degree = degree or 10
    cr:move_to(0, 0)
    cr:line_to(width - degree, 0)
    cr:line_to(width, height)
    cr:line_to(degree, height)
    cr:close_path()
end

function wibar.rightmost_parallelogram(cr, width, height, degree)
    degree = degree or 10
    cr:move_to(degree, 0)
    cr:line_to(width, 0)
    cr:line_to(width, height)
    cr:line_to(0, height)
    cr:close_path()
end

function wibar.leftmost_parallelogram(cr, width, height, degree)
    degree = degree or 10
    cr:move_to(0, 0)
    cr:line_to(width - degree, 0)
    cr:line_to(width, height)
    cr:line_to(0, height)
    cr:close_path()
end

function wibar.create_parallelogram(widget, parallelogram, color, margin)
    return wibox.widget {
        {
            widget,
            top = margin or beautiful.gap,
            bottom = margin or beautiful.gap,
            left  = parallelogram == wibar.leftmost_parallelogram and beautiful.gap or beautiful.big_gap,
            right = parallelogram == wibar.rightmost_parallelogram and beautiful.gap or beautiful.big_gap,
            widget = wibox.container.margin
        },
        shape = parallelogram,
        bg = color,
        widget = wibox.container.background
    }
end


function wibar.compose_parallelogram(left_widget, right_widget, left_shape, right_shape, margin)
    return wibox.widget {
        {
            {
                left_widget,
                left = left_shape == wibar.right_parallelogram and beautiful.big_gap or beautiful.gap,
                right = beautiful.big_gap,
                widget = wibox.container.margin
            },
            shape = left_shape,
            bg = beautiful.fg4,
            widget = wibox.container.background
        },
        {
            {
                right_widget,
                top = margin or beautiful.gap,
                bottom = margin or beautiful.gap,
                left = beautiful.big_gap,
                right = right_shape == wibar.right_parallelogram and beautiful.big_gap or beautiful.gap,
                widget = wibox.container.margin
            },
            shape = right_shape,
            bg = beautiful.bg1,
            widget = wibox.container.background
        },
        spacing = beautiful.big_negative_gap,
        layout = wibox.layout.fixed.horizontal
    }
end

return wibar
