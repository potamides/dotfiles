local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")

local net_widget = {}

local function read_wireless(stdout, interface)
  local match = stdout:match(interface .. ": " .. "%d+   (%d+)")

  if match then
    local signal_strength = math.floor(match / 70 * 100)
    local index           = signal_strength // 20

    return {signal_strength, "wireless_" .. index .. ".svg"}
  end
end

local function read_wired(stdout)
  local match = stdout:match("up\n$")

  if match then
    return {100, "wired.svg"}
  else
    return {0, "wired_na.svg"}
  end
end

function net_widget.init(args)
  args = args or {}

  args.wireless_interface = args.wireless_interface or "wlp5s0"
  args.wired_interface    = args.wired_interface or "enp3s0"
  args.path_to_icons      = args.path_to_icons or awful.util.getdir("config").."themes/gruvbox/widgets/net/"
  args.timeout            = args.timeout or 15

  local cmd = "cat /proc/net/wireless /sys/class/net/" .. args.wired_interface .. "/operstate"

  net_widget.image = wibox.widget {
    image  = args.path_to_icons .. "wired_na.svg",
    resize = false,
    widget = wibox.widget.imagebox,
  }
  net_widget.text = wibox.widget.textbox()
  net_widget.text:set_markup(string.format("<span color=%q><b>%s%%</b></span>", beautiful.bg_normal, 0))

  net_widget.text = awful.widget.watch(cmd, args.timeout, function(widget, stdout)
    local result          = read_wireless(stdout, args.wireless_interface) or read_wired(stdout)
    local strength, image = table.unpack(result)

    widget:set_markup(string.format("<span color=%q><b>%s%%</b></span>", beautiful.bg_normal, strength))
    net_widget.image:set_image(args.path_to_icons .. image)
  end)

end

return net_widget
