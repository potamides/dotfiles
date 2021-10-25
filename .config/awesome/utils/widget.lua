local beautiful = require("beautiful")
local wibox     = require("wibox")
local shape     = require("utils.shape")


local widget = {}

function widget.compose(args)
  local widgets = {
    spacing = beautiful.big_negative_gap,
    layout = wibox.layout.fixed.horizontal
  }

  for _, w in ipairs(args) do
    table.insert(widgets, {
      {
        w[1],
        top = w.margin or nil,
        bottom = w.margin or nil,
        left = w.shape == shape.rightangled.left and beautiful.gap or beautiful.big_gap,
        right = w.shape == shape.rightangled.right and beautiful.gap or beautiful.big_gap,
        widget = wibox.container.margin
      },
      shape = w.shape,
      bg = w.color,
      widget = wibox.container.background
    })
  end

  return #widgets == 1 and widgets[1] or widgets
end

return widget
