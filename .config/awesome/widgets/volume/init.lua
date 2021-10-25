local beautiful = require("beautiful")
local wibox = require("wibox")
local spawn = require("awful.spawn")

local volume = {}
local volume_icon_name = "audio-volume-high-symbolic"

local function parse_output(stdout)
  local level = string.match(stdout, "(%d?%d?%d)%%")
  if stdout:find("%[off%]") then
    volume_icon_name = "audio-volume-muted-symbolic"
    return "OFF"
  end
  level = tonumber(string.format("% 3d", level))

  if (level >= 0 and level < 25) then
    volume_icon_name = "audio-volume-off-symbolic"
  elseif (level < 50) then
    volume_icon_name = "audio-volume-low-symbolic"
  elseif (level < 75) then
    volume_icon_name = "audio-volume-medium-symbolic"
  else
    volume_icon_name = "audio-volume-high-symbolic"
  end
  return level.."%"
end

local function exec_cmd_and_update(cmd)
  spawn.easy_async(cmd, function(stdout)
    local txt = parse_output(stdout)
    volume.image.image = volume.path_to_icons .. volume_icon_name .. ".svg"
    volume.text:set_markup(string.format("<span color=%q><b>%s</b></span>", beautiful.bg_normal, txt))
  end)
end

function volume.toggle()
  exec_cmd_and_update('amixer ' .. volume.device .. ' sset Master toggle')
end

function volume.raise()
  exec_cmd_and_update('amixer ' .. volume.device .. ' sset Master 5%+')
end
function volume.lower()
  exec_cmd_and_update('amixer ' .. volume.device .. ' sset Master 5%-')
end

function volume.init(args)
  args = args or {}
  args.volume_audio_controller = args.volume_audio_controller or 'pulse'
  volume.path_to_icons = args.path_to_icons or beautiful.theme_path .. "/widgets/volume/"
  volume.device = args.volume_audio_controller == 'pulse' and '-D pulse' or ''

  volume.text = wibox.widget.textbox()
  volume.text:set_markup(string.format("<span color=%q><b>%s</b></span>", beautiful.bg_normal, "OFF"))
  volume.image = wibox.widget{
    image = volume.path_to_icons .. "audio-volume-muted-symbolic.svg",
    widget = wibox.widget.imagebox,
  }

  exec_cmd_and_update('amixer ' .. volume.device .. ' sget Master')
  volume.image:connect_signal("button::press", function(_,_,_,button)
    if     (button == 4) then volume.raise()
    elseif (button == 5) then volume.lower()
    elseif (button == 1) then volume.toggle()
    end
  end)
end

return volume
