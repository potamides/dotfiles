local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local dpi       = require("beautiful.xresources").apply_dpi
local cache     = require("gears.cache")

local run_shell = wibox.widget.textbox()
local widget    = {}

function widget.new()
  local widget_instance = {}

  function widget_instance._create_wibox()
    local w = wibox {
      visible      = false,
      ontop        = true,
      height       = (beautiful.run_shell_height or dpi(50))  + 2 * beautiful.border_width,
      width        = (beautiful.run_shell_width or dpi(200)) + 2 * beautiful.border_width,
      bg           = beautiful.bg_normal,
      border_color = beautiful.border_focus,
      border_width = beautiful.border_width,
    }
    w:setup {
      run_shell,
      left   = dpi(10),
      layout = wibox.container.margin,
    }

    return w
  end

  widget_instance._cache = cache.new(widget_instance._create_wibox)

  function widget_instance:launch(args)
    local w = self._cache:get()
    local min_width = w.width
    w.visible = true
    awful.placement.centered(w, {parent = awful.screen.focused()})

    args.textbox = run_shell
    args.bg_cursor = beautiful.border_focus
    args.done_callback = function()
      w.visible = false
      w.width = min_width
    end
    args.changed_callback = function()
      w.width = math.max(run_shell:get_preferred_size() + 2 * w:get_widget():get_left(), min_width)
      awful.placement.centered(w)
    end
    awful.prompt.run(args)
  end

  return widget_instance
end

local function get_default_widget()
  if not widget.default_widget then
    widget.default_widget = widget.new()
  end
  return widget.default_widget
end

function widget.launch(args)
  return get_default_widget():launch(args or {})
end

return widget
