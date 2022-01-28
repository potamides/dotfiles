local wibox     = require("wibox")
local beautiful = require("beautiful")
local monitor   = require("utils.monitor")

local net_widget = {}

local function read_wireless(content, interface)
  local match = content:match(interface .. ": " .. "%d+   (%d+)")

  if match then
    local signal_strength = math.floor(match / 70 * 100)
    local index           = math.floor(math.min(4, signal_strength / 20))

    return {signal_strength .. "%", "wireless_" .. index .. ".svg"}
  end
end

local function read_wired(content)
  local match = content:match("up\n$")

  if match then
    return {"100%", "wired.svg"}
  else
    return {"OFF", "wired_na.svg"}
  end
end

function net_widget.init(args)
  args = args or {}

  args.wireless_interface = args.wireless_interface or "wlp5s0"
  args.wired_interface    = args.wired_interface or "enp3s0"
  args.path_to_icons      = args.path_to_icons or beautiful.theme_path .. "/widgets/net/"
  args.timeout            = args.timeout or 15

  net_widget.image = wibox.widget {
    image  = args.path_to_icons .. "wired_na.svg",
    widget = wibox.widget.imagebox,
  }
  net_widget.text = wibox.widget.textbox()
  net_widget.text:set_markup(beautiful.widget_markup:format(beautiful.bg_normal, "OFF"))

  monitor("/proc/net/wireless", "/sys/class/net/" .. args.wired_interface .. "/operstate", function(content)
    local result = read_wireless(content, args.wireless_interface) or read_wired(content)

    net_widget.text:set_markup(beautiful.widget_markup:format(beautiful.bg_normal, result[1]))
    net_widget.image:set_image(args.path_to_icons .. result[2])
  end, args.timeout)

end

return net_widget
