local beautiful = require("beautiful")
local wibox = require("wibox")
local spawn = require("awful.spawn")

local volume = {}

local function set_volume(level)
  local icon, state = "audio-volume-high-symbolic", level and (level .. "%") or "OFF"

  if not level then
    icon = "audio-volume-muted-symbolic"
  elseif (level >= 0 and level < 25) then
    icon = "audio-volume-off-symbolic"
  elseif (level < 50) then
    icon = "audio-volume-low-symbolic"
  elseif (level < 75) then
    icon = "audio-volume-medium-symbolic"
  end

  volume.image.image = volume.path_to_icons .. icon .. ".svg"
  volume.text:set_markup(string.format("<span color=%q><b>%s</b></span>", beautiful.bg_normal, state))
end

local function update_widget()
  spawn.easy_async("pactl get-sink-mute @DEFAULT_SINK@", function(mute)
    if mute:match("yes") then
      set_volume(false)
    else
      spawn.easy_async("pactl get-sink-volume @DEFAULT_SINK@", function(vol)
        set_volume(tonumber(vol:match("(%d+)%%")))
      end)
    end
  end)
end

local function subscribe()
  local pid = spawn.with_line_callback("pactl subscribe", {stdout = function(event)
    if event:match("change.*sink[^-]") then
      update_widget()
    end
  end})

  if type(pid) == "number" then
    awesome.connect_signal("exit", function() spawn("kill " .. pid, false) end)
  end
end

function volume.toggle()
  spawn.easy_async("pactl set-sink-mute @DEFAULT_SINK@ toggle", update_widget)
end

function volume.raise()
  spawn.easy_async("pactl set-sink-volume @DEFAULT_SINK@ +" .. volume.step .. "%", update_widget)
end

function volume.lower()
  spawn.easy_async("pactl set-sink-volume @DEFAULT_SINK@ -" .. volume.step .. "%", update_widget)
end

function volume.init(args)
  args = args or {}
  volume.step = args.step or 5
  volume.path_to_icons = args.path_to_icons or beautiful.theme_path .. "/widgets/volume/"

  volume.text = wibox.widget.textbox()
  volume.image = wibox.widget.imagebox()
  set_volume(false)
  update_widget()
  subscribe()

  volume.image:connect_signal("button::press", function(_, _, _, button)
    if     (button == 4) then volume.raise()
    elseif (button == 5) then volume.lower()
    elseif (button == 1) then volume.toggle()
    end
  end)
end

return volume
