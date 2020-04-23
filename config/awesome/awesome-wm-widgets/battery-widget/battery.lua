-------------------------------------------------
-- Battery Widget for Awesome Window Manager
-- Shows the battery status using the ACPI tool
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/battery-widget

-- @author Pavel Makhov
-- @copyright 2017 Pavel Makhov
-------------------------------------------------

local beautiful = require("beautiful")
local awful = require("awful")
local naughty = require("naughty")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local gfs = require("gears.filesystem")
local dpi = require('beautiful').xresources.apply_dpi

-- acpi sample outputs
-- Battery 0: Discharging, 75%, 01:51:38 remaining
-- Battery 0: Charging, 53%, 00:57:43 until charged

local battery_widget = {}
local function worker(args)
    args = args or {}

    local path_to_icons = args.path_to_icons or awful.util.getdir("config").."themes/gruvbox/widgets/battery/"
    local show_current_level = args.show_current_level or false

    local display_notification = args.display_notification or false
    local position = args.notification_position or "top_right"
    local enable_battery_warning = args.enable_battery_warning
    if enable_battery_warning == nil then
        enable_battery_warning = true
    end

    if not gfs.dir_readable(path_to_icons) then
        naughty.notify{
            title = "Battery Widget",
            text = "Folder with icons doesn't exist: " .. path_to_icons,
            preset = naughty.config.presets.critical
        }
    end

    local icon_widget = wibox.widget {
            image = path_to_icons .. "battery-empty%s-symbolic.svg",
            resize = false,
            widget = wibox.widget.imagebox,
    }
    local level_widget = wibox.widget.textbox()
    level_widget:set_markup(string.format("<span color=%q><b>%s%%</b></span>", beautiful.bg_normal, 0))

    -- Popup with battery info
    -- One way of creating a pop-up notification - naughty.notify
    local notification
    local function show_battery_status(batteryType)
        awful.spawn.easy_async([[bash -c 'acpi']],
        function(stdout, _, _, _)
            naughty.destroy(notification)
            notification = naughty.notify{
                text =  stdout,
                title = "Battery status",
                icon = path_to_icons .. batteryType .. ".svg",
                icon_size = dpi(16),
                position = position,
                timeout = 5, hover_timeout = 0.5,
                width = 200,
                screen = mouse.screen
            }
        end
        )
    end

    -- Alternative to naughty.notify - tooltip. You can compare both and choose the preferred one
    --battery_popup = awful.tooltip({objects = {battery_widget}})

    -- To use colors from beautiful theme put
    -- following lines in rc.lua before require("battery"):
    -- beautiful.tooltip_fg = beautiful.fg_normal
    -- beautiful.tooltip_bg = beautiful.bg_normal

    local function show_battery_warning(time)
      naughty.notify({ preset = naughty.config.presets.critical,
              title = "Battery is low!",
              text = string.format("About %sh left based on your usage.", time) })
    end
    local last_battery_check = os.time()
    local batteryType = "battery-good-symbolic"

    watch("acpi -i", 10,
    function(widget, stdout, _, _, _)
        local battery_info = {}
        local capacities = {}
            local status, charge_str, time
        for s in stdout:gmatch("[^\r\n]+") do
            status, charge_str, time = string.match(s, '.+: (%a+), (%d?%d?%d)%%,?(.*)')
            if status ~= nil then
                table.insert(battery_info, {status = status, charge = tonumber(charge_str)})
            else
                local cap_str = string.match(s, '.+:.+last full capacity (%d+)')
                table.insert(capacities, tonumber(cap_str))
            end
        end

        local capacity = 0
        for _, cap in ipairs(capacities) do
            capacity = capacity + cap
        end

        local charge = 0
        for i, batt in ipairs(battery_info) do
            if batt.charge >= charge then
                status = batt.status -- use most charged battery status
                -- this is arbitrary, and maybe another metric should be used
            end

            charge = charge + batt.charge * capacities[i]
        end
        charge = charge / capacity

        if show_current_level then
            level_widget:set_markup(string.format("<span color=%q><b>%s%%</b></span>",
                beautiful.bg_normal, math.floor(charge)))
        end

        if (charge >= 0 and charge < 15) then
            batteryType = "battery-empty%s-symbolic"
            if enable_battery_warning and status ~= 'Charging' and os.difftime(os.time(), last_battery_check) > 300 then
                -- if 5 minutes have elapsed since the last warning
                last_battery_check = os.time()

                show_battery_warning(time)
            end
        elseif (charge >= 15 and charge < 40) then batteryType = "battery-caution%s-symbolic"
        elseif (charge >= 40 and charge < 60) then batteryType = "battery-low%s-symbolic"
        elseif (charge >= 60 and charge < 80) then batteryType = "battery-good%s-symbolic"
        elseif (charge >= 80 and charge <= 100) then batteryType = "battery-full%s-symbolic"
        end

        if status == 'Charging' then
            batteryType = string.format(batteryType, '-charging')
        else
            batteryType = string.format(batteryType, '')
        end

        widget:set_image(path_to_icons .. batteryType .. ".svg")

        -- Update popup text
        -- battery_popup.text = string.gsub(stdout, "\n$", "")
    end,
    icon_widget)

    if display_notification then
        icon_widget:connect_signal("mouse::enter", function() show_battery_status(batteryType) end)
        icon_widget:connect_signal("mouse::leave", function() naughty.destroy(notification) end)
    end
    return level_widget, icon_widget
end

return setmetatable(battery_widget, { __call = function(_, ...) return worker(...) end })
