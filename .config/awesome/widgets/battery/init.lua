local beautiful = require("beautiful")
local naughty = require("naughty")
local monitor = require("utils.monitor")
local wibox = require("wibox")
local merge = require("gears.table").merge
local new_for_path = require("lgi").Gio.File.new_for_path
local unpack = unpack or table.unpack -- luacheck: globals unpack (compatibility with Lua 5.1)

local battery_widget = {}

local function show_battery_warning(time)
  naughty.notify({ preset = naughty.config.presets.critical,
    title = "Battery is low!",
    text = string.format("About %smin left based on your usage.", time) })
end

local function parse_battery_info(content)
  local battery_info = {}
  for status, power, energy, charge in content:gmatch(
    '.*STATUS=(%a+).+POWER_NOW=(%d+).+ENERGY_NOW=(%d+).+CAPACITY=(%d+)') do
      table.insert(battery_info, {status = status, charge = charge, power = power, energy = energy})
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
  charge = math.min(charge / #battery_info, 100)
  time = 60 * time -- minutes

  return charge, status, time
end

local function get_batteries()
  local dir, batteries = new_for_path("/sys/class/power_supply/"), {}
  local files = dir:enumerate_children('standard::name', 'NONE')

  local file = files:next_file()
  while file do
    if file:get_name():match("BAT%d+") then
      table.insert(batteries, string.format("%s/%s/uevent", dir:get_path(), file:get_name()))
    end
    file = files:next_file()
  end

  return batteries
end

function battery_widget.init(args)
  args = args or {}
  args.path_to_icons = args.path_to_icons or beautiful.theme_path .. "/widgets/battery/"
  args.disable_battery_warning = args.disable_battery_warning or false
  args.timeout = args.timeout or 15

  battery_widget.image = wibox.widget {
    image = args.path_to_icons .. "battery-empty-symbolic.svg",
    widget = wibox.widget.imagebox,
  }
  battery_widget.text = wibox.widget.textbox()
  battery_widget.text:set_markup(beautiful.widget_markup:format(beautiful.bg_normal, "0%"))

  local last_battery_check = os.time()
  local batteryType = "battery-good-symbolic"

  monitor(unpack(merge(get_batteries(), {function(content)
    local charge, status, time = parse_battery_info(content)
    battery_widget.text:set_markup(beautiful.widget_markup:format(beautiful.bg_normal, math.floor(charge) .. "%"))

    if (charge >= 0 and charge < 15) then
      batteryType = "battery-empty%s-symbolic"
      if not args.disable_battery_warning and status ~= 'Charging'
        and os.difftime(os.time(), last_battery_check) > 300 then
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

    battery_widget.image:set_image(args.path_to_icons .. batteryType .. ".svg")

  end, args.timeout})))
end

return battery_widget
