-------------------------------------------------
-- Volume Widget for Awesome Window Manager
-- Shows the current volume level
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/volume-widget

-- @author Pavel Makhov
-- @copyright 2017 Pavel Makhov
-------------------------------------------------

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local watch = require("awful.widget.watch")
local spawn = require("awful.spawn")

local path_to_icons = awful.util.getdir("config").."/volume/symbolic/"
local request_command = 'amixer -D pulse sget Master'

local volume_widget = wibox.widget {
    {
        id = "icon",
        image = path_to_icons .. "audio-volume-muted-symbolic.svg",
        resize = false,
        widget = wibox.widget.imagebox,
    },
    layout = wibox.container.margin(nil, 0, 0, 4),
    set_image = function(self, path)
        self.icon.image = path
    end
}

local text_volume_widget = wibox.widget.textbox()
text_volume_widget:set_markup(string.format("<span color=%q><b>%s</b></span>", beautiful.bg_normal, "--"))

local update_graphic = function(widget, stdout, _, _, _)
    local mute = string.match(stdout, "%[(o%D%D?)%]")
    local volume_str = string.match(stdout, "(%d?%d?%d)%%")
    local volume = tonumber(string.format("% 3d", volume_str))
    local volume_icon_name

    -- only update widget when something changes
    if (mute == "on" and text_volume_widget.text ~= volume_str .. "%") or
        (mute == "off" and text_volume_widget.text ~= "OFF") then
        if mute == "off" then volume_icon_name="audio-volume-muted-symbolic"
        elseif (volume >= 0 and volume < 25) then volume_icon_name="audio-volume-off-symbolic"
        elseif (volume < 50) then volume_icon_name="audio-volume-low-symbolic"
        elseif (volume < 75) then volume_icon_name="audio-volume-medium-symbolic"
        elseif (volume <= 100) then volume_icon_name="audio-volume-high-symbolic"
        end

        -- Update image
        widget.image = path_to_icons .. volume_icon_name .. ".svg"

        -- Update volume text
        if mute == "off" then
            text_volume_widget:set_markup(string.format("<span color=%q><b>%s</b></span>", beautiful.bg_normal, "OFF"))
        else
            text_volume_widget:set_markup(string.format("<span color=%q><b>%s%%</b></span>", beautiful.bg_normal, volume_str))
        end
    end
end

--[[ allows control volume level by:
- clicking on the widget to mute/unmute
- scrolling when cursor is over the widget
]]
volume_widget:connect_signal("button::press", function(_,_,_,button)
    if (button == 4)     then awful.spawn("amixer -D pulse sset Master 5%+", false)
    elseif (button == 5) then awful.spawn("amixer -D pulse sset Master 5%-", false)
    elseif (button == 1) then awful.spawn("amixer -D pulse sset Master toggle", false)
    end

    spawn.easy_async(request_command, function(stdout, stderr, exitreason, exitcode)
        update_graphic(volume_widget, stdout, stderr, exitreason, exitcode)
    end)
end)

watch(request_command, 1, update_graphic, volume_widget)


local volume = {text = text_volume_widget, img = volume_widget}

return volume
