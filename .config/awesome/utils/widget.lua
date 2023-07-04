local beautiful = require("beautiful")
local wibox     = require("wibox")
local ushape     = require("utils.shape")


local widget = {}

local function get_margin(shape, side)
  if side == "left" then
    if shape == ushape.rightangled.left then
      return beautiful.gap
    elseif shape == ushape.rightangled.left_mirrored then
      return beautiful.med_gap
    end
  elseif side == "right" then
    if shape == ushape.rightangled.right then
      return beautiful.gap
    elseif shape == ushape.rightangled.right_mirrored then
      return beautiful.med_gap
    end
  end

  return beautiful.big_gap
end

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
        left = get_margin(w.shape, "left"),
        right = get_margin(w.shape, "right"),
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
