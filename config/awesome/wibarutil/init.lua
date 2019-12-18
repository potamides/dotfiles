local dpi = require("beautiful.xresources").apply_dpi
local beautiful = require("beautiful")
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")


-- a seperator that makes a rectangle look like a parallelogram
local separator = function(left_color, right_color, draw_space, reverse)
    local margin
    if draw_space then
        margin = -8
    else
        margin = -14
    end

    local left_shape
    local right_shape
    if reverse then
        left_shape = function(cr, width, height)
            cr:move_to(0, 0)
            cr:line_to(width, height)
            cr:line_to(0, height)
            cr:line_to(0, 0)
            cr:line_to(0, 0)
            cr:close_path()
        end
        right_shape = function(cr, width, height)
            cr:move_to(width, height)
            cr:move_to(width, height)
            cr:line_to(0, 0)
            cr:line_to(width, 0)
            cr:line_to(width, height)
            cr:close_path()
        end
    else
        left_shape = function(cr, width, height)
            cr:move_to(0, height)
            cr:line_to(width, 0)
            cr:line_to(0, 0)
            cr:line_to(0, height)
            cr:line_to(0, height)
            cr:close_path()
        end
        right_shape = function(cr, width, height)
            cr:move_to(0, height)
            cr:line_to(width, 0)
            cr:line_to(width, 0)
            cr:line_to(width, height)
            cr:line_to(0, height)
            cr:close_path()
        end
    end

    return
        wibox.widget {
            wibox.widget {{
                    widget = wibox.widget.textbox
                },
                shape              = left_shape,
                bg                 = left_color,
                shape_border_color = beautiful.border_color,
                forced_width       = 13,
                widget             = wibox.container.background
            },
            wibox.widget {{
                    widget = wibox.widget.textbox
                },
                shape              = right_shape,
                bg                 = right_color,
                shape_border_color = beautiful.border_color,
                forced_width       = 13,
                widget             = wibox.container.background
            },
            spacing = margin,
            forced_num_cols = 2,
            forced_num_rows = 1,
            expand          = true,
            homogeneous     = true,
            layout          = wibox.layout.grid.horizontal
        }
end

-- surrounds a widget with a colored rectangle
local function rectangle(widget, color, lmargin, rmargin)
return wibox.widget {
        {
                widget,
            left   = lmargin or 4,
            right  = rmargin or 4,
            top    = 0,
            bottom = 0,
            widget = wibox.container.margin
        },
        shape              = gears.shape.rectangle,
        bg                 = color,
        widget             = wibox.container.background
    }
end

-- custom list_update function, adds a seperator after each tag to make them
-- look like parallelograms
local last_separator
local function list_update(left_color)
    return function(w, buttons, label, data, objects)
        local previous_color = left_color
        -- update the widgets, creating them if needed
        w:reset()
        for i, o in ipairs(objects) do
            local cache = data[o]
            local ib, tb, bgb, tbm, ibm, sep, l
            if cache then
                ib = cache.ib
                tb = cache.tb
                bgb = cache.bgb
                tbm = cache.tbm
                ibm = cache.ibm
                sep = cache.sep
            else
                ib = wibox.widget.imagebox()
                tb = wibox.widget.textbox()
                bgb = wibox.container.background()
                tbm = wibox.container.margin(tb, dpi(4), dpi(4))
                ibm = wibox.container.margin(ib, dpi(4))
                sep = separator(nil, nil, true, true)
                l = wibox.layout.fixed.horizontal()

                -- All of this is added in a fixed widget
                l:fill_space(true)
                l:add(ibm)
                l:add(tbm)

                -- And all of this gets a background
                bgb:set_widget(l)

                bgb:buttons(awful.widget.common.create_buttons(buttons, o))


                data[o] = {
                    ib  = ib,
                    tb  = tb,
                    bgb = bgb,
                    tbm = tbm,
                    ibm = ibm,
                    sep = sep,
                }
            end

            local text, bg, bg_image, icon, args = label(o, tb)
            args = args or {}

            -- The text might be invalid, so use pcall.
            if text == nil or text == "" then
                tbm:set_margins(0)
            else
                if not tb:set_markup_silently(text) then
                    tb:set_markup("<i>&lt;Invalid text&gt;</i>")
                end
            end
            bgb:set_bg(bg)
            if type(bg_image) == "function" then
                bg_image = bg_image(tb,o,nil,objects,i)
            end
            bgb:set_bgimage(bg_image)
            if icon then
                ib:set_image(icon)
            else
                ibm:set_margins(0)
            end

            bgb.shape              = args.shape
            bgb.shape_border_width = args.shape_border_width
            bgb.shape_border_color = args.shape_border_color

            -- don't add the revelation tags
            if not (tb.text == "Revelation" or tb.text == "Revelation_zoom") then
                local left_sep = sep:get_widgets_at(1,1)[1]
                local right_sep = sep:get_widgets_at(1,2)[1]
                left_sep.bg = previous_color
                right_sep.bg = bg or beautiful.bg_normal
                w:add(sep)
                previous_color = bg or beautiful.bg_normal

                w:add(bgb)
            end
        end

        if data.end_sep then
            data.end_sep:get_widgets_at(1,1)[1].bg = previous_color
        else
            data.end_sep = separator(previous_color, beautiful.bg_normal, true, true)
        end
        w:add(data.end_sep)
        last_separator = data.end_sep:get_widgets_at(1,2)[1]
    end
end

local function set_last_separator_color(color)
    if last_separator then
        last_separator.bg = gears.color(color)
    end
end

local wibarutil = {separator = separator, rectangle = rectangle, list_update = list_update,
                   set_last_separator_color = set_last_separator_color}

return wibarutil
