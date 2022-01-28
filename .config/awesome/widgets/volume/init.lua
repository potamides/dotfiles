local beautiful = require("beautiful")
local wibox = require("wibox")
local spawn = require("awful.spawn")

local volume = {
  volume = {
    get = "pactl get-sink-volume @DEFAULT_SINK@",
    set = "pactl set-sink-volume @DEFAULT_SINK@ %+d%%",
  },
  mute = {
    get = "pactl get-sink-mute @DEFAULT_SINK@",
    set = "pactl set-sink-mute @DEFAULT_SINK@ %s",
  },
  subscribe = "pactl subscribe"
}

local function display_volume(level)
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
  volume.text:set_markup(beautiful.widget_markup:format(beautiful.bg_normal, state))
end

local function update_widget()
  spawn.easy_async(volume.mute.get, function(mute)
    if mute:match("yes") then
      display_volume(false)
    else
      spawn.easy_async(volume.volume.get, function(vol)
        display_volume(tonumber(vol:match("(%d+)%%")))
      end)
    end
  end)
end

local function subscribe()
  local pid = spawn.with_line_callback(volume.subscribe, {stdout = function(event)
    if event:match("change.*sink[^-]") then
      update_widget()
    end
  end})

  if type(pid) == "number" then
    awesome.connect_signal("exit", function() awesome.kill(pid, awesome.unix_signal.SIGTERM) end)
  end
end

function volume.toggle()
  spawn(volume.mute.set:format("toggle"), false)
end

function volume.raise()
  spawn.easy_async(volume.volume.get, function(vol)
    local step = math.min(volume.step, math.max(volume.max - tonumber(vol:match("(%d+)%%")), 0))
    spawn(volume.volume.set:format(step), false)
  end)
end

function volume.lower()
  spawn(volume.volume.set:format(-volume.step), false)
end

function volume.init(args)
  args = args or {}
  volume.step = args.step or 5
  volume.max = args.max or 130
  volume.path_to_icons = args.path_to_icons or beautiful.theme_path .. "/widgets/volume/"

  volume.text = wibox.widget.textbox()
  volume.image = wibox.widget.imagebox()
  display_volume(false)
  update_widget()
  subscribe()

  volume.image:connect_signal("button::press", function(_, _, _, button)
    if     button == 4 then volume.raise()
    elseif button == 5 then volume.lower()
    elseif button == 1 then volume.toggle()
    end
  end)
end

return volume
