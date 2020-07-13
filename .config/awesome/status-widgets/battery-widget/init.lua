-------------------------------------------------
-- Battery Widget for Awesome Window Manager
-- Shows the battery status
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

local battery_widget = {}
function battery_widget.init(args)
    args = args or {}

    local path_to_icons = args.path_to_icons or awful.util.getdir("config") .. "themes/gruvbox/widgets/battery/"

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

    battery_widget.image = wibox.widget {
        image = path_to_icons .. "battery-empty-symbolic.svg",
        widget = wibox.widget.imagebox,
    }
    battery_widget.text = wibox.widget.textbox()
    battery_widget.text:set_markup(string.format("<span color=%q><b>%s%%</b></span>", beautiful.bg_normal, 0))

    -- Alternative to naughty.notify - tooltip. You can compare both and choose the preferred one
    --battery_popup = awful.tooltip({objects = {battery_widget}})

    -- To use colors from beautiful theme put
    -- following lines in rc.lua before require("battery"):
    -- beautiful.tooltip_fg = beautiful.fg_normal
    -- beautiful.tooltip_bg = beautiful.bg_normal

    local function show_battery_warning(time)
      naughty.notify({ preset = naughty.config.presets.critical,
              title = "Battery is low!",
              text = string.format("About %smin left based on your usage.", time) })
    end
    local last_battery_check = os.time()
    local batteryType        = "battery-good-symbolic"
    local battery_path       = "/sys/class/power_supply/BAT%d/uevent"

    -- watch up to 3 batteries
    watch(string.format("cat %s %s %s", battery_path:format(0), battery_path:format(1), battery_path:format(2)),  15,
    function(widget, stdout, _, _, _)
        local battery_info = {}
        for status, power , energy, charge_str in stdout:gmatch('.*POWER_SUPPLY_STATUS=(%a+).+\
POWER_SUPPLY_POWER_NOW=(%d+).+POWER_SUPPLY_ENERGY_NOW=(%d+).+POWER_SUPPLY_CAPACITY=(%d+)') do
          table.insert(battery_info, {status = status, charge = charge_str, power = power, energy = energy})
        end
        local charge = 0
        local time   = 0
        local status = "Unknown"
        for _, batt in pairs(battery_info) do
            if batt.status == 'Charging' then
                status = batt.status
            elseif batt.status == 'Discharging' then
              time = time + batt.energy / batt.power
            end

            charge = charge + batt.charge
        end
        charge = charge / #battery_info
        time   = 60 * time -- minutes

        battery_widget.text:set_markup(string.format("<span color=%q><b>%s%%</b></span>",
            beautiful.bg_normal, math.floor(charge)))

        if (charge >= 0 and charge < 15) then
            batteryType = "battery-empty%s-symbolic"
            if enable_battery_warning and status ~= 'Charging' and os.difftime(os.time(), last_battery_check) > 300 then
                -- if 5 minutes have elapsed since the last warning
                last_battery_check = os.time()

                show_battery_warning(math.floor(time))
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
        collectgarbage("step", 128)
    end,
    battery_widget.image)
end

return battery_widget
