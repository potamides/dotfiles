local awful = require("awful")
local beautiful = require("beautiful")
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

function patches.apply()
  for _, patch in pairs(patches.fix) do
    patch()
  end
end

return patches
