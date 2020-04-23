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

local PATH_TO_ICONS = awful.util.getdir("config").."/volume/symbolic/"
local volume_widget = wibox.widget {
        image = PATH_TO_ICONS .. "audio-volume-muted-symbolic.svg",
        resize = false,
        widget = wibox.widget.imagebox,
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
        widget.image = PATH_TO_ICONS .. volume_icon_name .. ".svg"

        -- Update volume text
        if mute == "off" then
            text_volume_widget:set_markup(string.format("<span color=%q><b>%s</b></span>", beautiful.bg_normal, "OFF"))
        else
            text_volume_widget:set_markup(string.format("<span color=%q><b>%s%%</b></span>", beautiful.bg_normal, volume_str))
        end
    end
end

local function increase()
  spawn.easy_async("amixer -D pulse sset Master 5%+",
    function(stdout, stderr, exitreason, exitcode)
      update_graphic(volume_widget, stdout, stderr, exitreason, exitcode)
    end)
end

local function decrease()
  spawn.easy_async("amixer -D pulse sset Master 5%-",
    function(stdout, stderr, exitreason, exitcode)
      update_graphic(volume_widget, stdout, stderr, exitreason, exitcode)
    end)
end

local function mute()
  spawn.easy_async("amixer -D pulse sset Master toggle",
    function(stdout, stderr, exitreason, exitcode)
      update_graphic(volume_widget, stdout, stderr, exitreason, exitcode)
    end)
end

--[[ allows control volume level by:
- clicking on the widget to mute/unmute
- scrolling when cursor is over the widget
]]
volume_widget:connect_signal("button::press", function(_,_,_,button)
    if (button == 4)     then increase()
    elseif (button == 5) then decrease()
    elseif (button == 1) then mute()
    end
end)

watch( "amixer -D pulse sget Master", 30, update_graphic, volume_widget)


local volume = {text = text_volume_widget, img = volume_widget,
                increase = increase, decrease = decrease, mute = mute}

return volume
