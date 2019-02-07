local dpi = require("beautiful.xresources").apply_dpi
local beautiful = require("beautiful")
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")


-- a seperator that makes a square look like a parallelogram
local separator = function(left_color, right_color, draw_space, reverse)
    local margin = 3
    local space = -1
    if draw_space then
        margin = 0
        space = 6
    end

    local separator_shape = function(cr, width, height)
        if reverse then
            cr:set_source(gears.color(left_color))
            cr:move_to(margin, 0)
            cr:line_to(width-space-margin, height)
            cr:line_to(0, height)
            cr:line_to(0, 0)
            cr:line_to(margin, 0)
            cr:fill()
            cr:set_source(gears.color(right_color))
            cr:move_to(width, height)
            cr:move_to(width-margin, height)
            cr:line_to(space+margin, 0)
            cr:line_to(width, 0)
            cr:line_to(width, height)
            cr:fill()
        else
            cr:set_source(gears.color(left_color))
            cr:move_to(margin, height)
            cr:line_to(width-space-margin, 0)
            cr:line_to(0, 0)
            cr:line_to(0, height)
            cr:line_to(margin, height)
            cr:fill()
            cr:set_source(gears.color(right_color))
            cr:move_to(space+margin, height)
            cr:line_to(width-margin, 0)
            cr:line_to(width, 0)
            cr:line_to(width, height)
            cr:line_to(space+margin, height)
            cr:fill()
        end
    end
    return wibox.widget {{
            widget = wibox.widget.textbox
        },
        shape              = separator_shape,
        bg                 = beautiful.bg_normal,
        shape_border_color = beautiful.border_color,
        forced_width = 20,
        widget             = wibox.container.background
    }
end

-- custom square shape
local function rectangle(widget, color, lmargin, rmargin)
return wibox.widget {
        {
                widget,
            left   = lmargin,
            right  = rmargin,
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
local function list_update(left_color)
    return function(w, buttons, label, data, objects)
        local previous_color = left_color
        -- update the widgets, creating them if needed
        w:reset()
        for i, o in ipairs(objects) do
            local cache = data[o]
            local ib, tb, bgb, tbm, ibm, l
            if cache then
                ib = cache.ib
                tb = cache.tb
                bgb = cache.bgb
                tbm = cache.tbm
                ibm = cache.ibm
            else
                ib = wibox.widget.imagebox()
                tb = wibox.widget.textbox()
                bgb = wibox.container.background()
                tbm = wibox.container.margin(tb, dpi(4), dpi(4))
                ibm = wibox.container.margin(ib, dpi(4))
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
                w:add(separator(previous_color, bg or beautiful.bg_normal, true, true))
                previous_color = bg or beautiful.bg_normal

                w:add(bgb)
            end
       end
       w:add(separator(previous_color, beautiful.bg_normal, true, true))
    end
end

local auxiliary = {separator = separator, rectangle = rectangle, list_update = list_update}

return auxiliary
