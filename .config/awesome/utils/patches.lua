local awful = require("awful")
local beautiful = require("beautiful")
local protected_call = require("gears.protected_call")
local timer = require("gears.timer")

local patches = {fix = {}}

-- awful.key does not work reliably in somewm. Shell out to wtype instead.
-- https://github.com/trip-zip/somewm/issues/644
function patches.fix.fake_input()
  local MOD = { Mod4 = "logo", Mod1 = "alt", Control = "ctrl", Shift = "shift", Mod5 = "altgr" }

  function awful.key.execute(mods, key)
    local m = ""
    for _, mod in ipairs(mods or {}) do
        if MOD[mod] then m = m .. "-M " .. MOD[mod] .. " " end
    end
    local k = (#key == 1) and ("-- " .. key) or ("-k " .. key)
    awful.spawn.with_shell("wtype " .. m .. k)
  end
end

-- the lockscreen can get stuck when we launch it while another keygrabber is running
-- TODO: open issue/PR for this
function patches.fix.stuck_lockscreen()
  local kb
  awesome.connect_signal("lock::activate", function()
    kb = awful.keygrabber.current_instance
    if kb then kb:stop() end
  end)
  awesome.connect_signal("lock::deactivate", function()
    if kb then kb:start() end
  end)
end

-- Lua config workaround for the red border flash on client startup
-- TODO: open issue/PR for this
function patches.fix.red_border_flash()
  timer.delayed_call(function()
    local real_border_width = beautiful.border_width or 0

    client.connect_signal("new", function()
      -- Force C's get_border_width() (window.c:448, runs right after this) to read 0.
      beautiful.border_width = 0
    end)

    client.connect_signal("request::manage", function(c)
      -- Creation is done; restore the theme value and apply the real width.
      beautiful.border_width = real_border_width
      c.border_width = real_border_width
    end)
  end)
end

function patches.apply()
  for _, patch in pairs(patches.fix) do
    patch()
  end
end

return patches
