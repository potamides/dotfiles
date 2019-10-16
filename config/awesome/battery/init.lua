-------------------------------------------------
-- Battery Widget for Awesome Window Manager
-- Shows the battery status using the ACPI tool
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/battery-widget

-- @author Pavel Makhov
-- @copyright 2017 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local watch = require("awful.widget.watch")
local wibox = require("wibox")

-- acpi sample outputs
-- Battery 0: Discharging, 75%, 01:51:38 remaining
-- Battery 0: Charging, 53%, 00:57:43 until charged

local PATH_TO_ICONS = awful.util.getdir("config").."/battery/symbolic/"

local battery_widget = wibox.widget {
    {
        id = "icon",
        widget = wibox.widget.imagebox,
        resize = false
    },
    layout = wibox.container.margin(nil, 0, 0, 4)
}

local should_notify = true
local text_battery_widget = wibox.widget.textbox()
text_battery_widget:set_markup(string.format("<span color=%q><b>%s</b></span>", beautiful.bg_normal, "--"))

watch("acpi", 60,
    function(widget, stdout, stderr, exitreason, exitcode)
        local batteryType
        local _, status, charge_str, time = string.match(stdout, '(.-): (%a+), (%d?%d?%d)%%,? ?(%d?%d?:?%d?%d?).*')
        local charge = tonumber(charge_str)

        if (charge >= 0 and charge < 15) then
            if should_notify and status ~= 'Charging' then
                naughty.notify({ preset = naughty.config.presets.critical,
                        title = "Battery is low!",
                        text = string.format("About %sh left based on your usage.", time) })
                should_notify = false
            end
            batteryType = "battery-empty%s-symbolic"
        elseif (charge >= 15 and charge < 40) then
            batteryType = "battery-caution%s-symbolic"
        elseif (charge >= 40 and charge < 60) then
            batteryType = "battery-low%s-symbolic"
        elseif (charge >= 60 and charge < 80) then
            batteryType = "battery-good%s-symbolic"
        elseif (charge >= 80 and charge <= 100) then
            batteryType = "battery-full%s-symbolic"
        end
        if status == 'Charging' then
            batteryType = string.format(batteryType, '-charging')
            should_notify = true
        else
            batteryType = string.format(batteryType, '')
        end
        widget.icon:set_image(PATH_TO_ICONS .. batteryType .. ".svg")

        -- Update text battery
        text_battery_widget:set_markup(string.format("<span color=%q><b>%s%%</b></span>",
            beautiful.bg_normal, charge_str))
    end,
    battery_widget)

local battery = {text = text_battery_widget, img = battery_widget}
return battery
