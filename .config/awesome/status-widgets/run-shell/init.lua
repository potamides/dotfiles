local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local dpi       = require("beautiful.xresources").apply_dpi

local run_shell = wibox.widget.textbox()
local widget    = {}

function widget.new()

    local widget_instance = {
        _cached_wiboxes = {}
    }

    function widget_instance._create_wibox()
        local w = wibox {
            visible      = false,
            ontop        = true,
            height       = dpi(50)  + 2 * beautiful.border_width,
            width        = dpi(200) + 2 * beautiful.border_width,
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

    function widget_instance:launch(opts)
        local s = awful.screen.focused()
        if not self._cached_wiboxes[s] then
            self._cached_wiboxes[s] = {}
        end
        if not self._cached_wiboxes[s][1] then
            self._cached_wiboxes[s][1] = self:_create_wibox()
        end
        local w = self._cached_wiboxes[s][1]
        local old_width = w.width
        w.visible = true
        awful.placement.centered(w, {parent = awful.screen.focused()})

        opts.textbox = run_shell
        opts.bg_cursor = beautiful.border_focus
        opts.done_callback = function()
          w.visible = false
          w.width = old_width
        end
        opts.changed_callback = function()
          local width = run_shell:get_preferred_size()
          local empty_area = w.width - 2 * beautiful.border_width - dpi(10) - width
          if empty_area < dpi(10) then
            w.width = w.width + dpi(10) - empty_area
            awful.placement.centered(w, {parent = awful.screen.focused()})
          end
        end
        awful.prompt.run(opts)
    end

    return widget_instance
end

local function get_default_widget()
    if not widget.default_widget then
        widget.default_widget = widget.new()
    end
    return widget.default_widget
end

function widget.launch(opts)
    return get_default_widget():launch(opts or {})
end

return widget
