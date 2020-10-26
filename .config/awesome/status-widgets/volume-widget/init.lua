local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local spawn = require("awful.spawn")
local naughty = require("naughty")
local dpi = require('beautiful').xresources.apply_dpi

local volume = {device = '', display_notification = false, notification = nil}
local volume_icon_name = "audio-volume-high-symbolic"
local path_to_icons = awful.util.getdir("config") .. "themes/gruvbox/widgets/volume/"

function volume.toggle()
    volume._cmd('amixer ' .. volume.device .. ' sset Master toggle')
end

function volume.raise()
    volume._cmd('amixer ' .. volume.device .. ' sset Master 5%+')
end
function volume.lower()
    volume._cmd('amixer ' .. volume.device .. ' sset Master 5%-')
end

local function parse_output(stdout)
    local level = string.match(stdout, "(%d?%d?%d)%%")
    if stdout:find("%[off%]") then
        volume_icon_name="audio-volume-muted-symbolic"
        return "OFF"
    end
    level = tonumber(string.format("% 3d", level))

    if (level >= 0 and level < 25) then
        volume_icon_name="audio-volume-off-symbolic"
    elseif (level < 50) then
        volume_icon_name="audio-volume-low-symbolic"
    elseif (level < 75) then
        volume_icon_name="audio-volume-medium-symbolic"
    else
        volume_icon_name="audio-volume-high-symbolic"
    end
    return level.."%"
end

local function update_widget(widget, stdout, _, _, _)
    local txt = parse_output(stdout)
    widget.image.image = path_to_icons .. volume_icon_name .. ".svg"
    widget.text:set_markup(string.format("<span color=%q><b>%s</b></span>", beautiful.bg_normal, txt))
    if volume.display_notification then
        volume.notification.iconbox.image = path_to_icons .. volume_icon_name .. ".svg"
        naughty.replace_text(volume.notification, "Volume", txt)
    end
end

local function notif(msg, keep)
    if volume.display_notification then
        naughty.destroy(volume.notification)
        volume.notification= naughty.notify{
            text =  msg,
            icon = path_to_icons .. volume_icon_name .. ".svg",
            icon_size = dpi(16),
            title = "Volume",
            position = volume.position,
            timeout = keep and 0 or 2, hover_timeout = 0.5,
            width = 200,
            screen = mouse.screen
        }
    end
end

function volume.init(args)
    args = args or {}
    args.volume_audio_controller = args.volume_audio_controller or 'pulse'
    path_to_icons = args.path_to_icons or path_to_icons
    volume.display_notification = args.display_notification or false
    volume.position = args.notification_position or "top_right"

    if args.volume_audio_controller == 'pulse' then
        volume.device = '-D pulse'
    end
    local get_volume_cmd = 'amixer ' .. volume.device .. ' sget Master'

    volume.image = wibox.widget{
        image = path_to_icons .. "audio-volume-muted-symbolic.svg",
        widget = wibox.widget.imagebox,
    }
    volume.text = wibox.widget.textbox()
    volume.text:set_markup(string.format("<span color=%q><b>%s</b></span>", beautiful.bg_normal, "OFF"))

    function volume._cmd(cmd)
        notif("")
        spawn.easy_async(cmd, function(stdout, stderr, exitreason, exitcode)
            update_widget(volume, stdout, stderr, exitreason, exitcode)
        end)
    end

    volume._cmd(get_volume_cmd)
    local function show()
        spawn.easy_async(get_volume_cmd,
        function(stdout, _, _, _)
        local txt = parse_output(stdout)
        notif(txt, true)
        end
        )
    end

    volume.image:connect_signal("button::press", function(_,_,_,button)
        if (button == 4)     then volume.raise()
        elseif (button == 5) then volume.lower()
        elseif (button == 1) then volume.toggle()
        end
    end)
    if volume.display_notification then
        volume.image:connect_signal("mouse::enter", function() show() end)
        volume.image:connect_signal("mouse::leave", function() naughty.destroy(volume.notification) end)
    end
end

return volume
