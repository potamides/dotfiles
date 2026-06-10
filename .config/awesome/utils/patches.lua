local awful = require("awful")
local beautiful = require("beautiful")
local protected_call = require("gears.protected_call")
local timer = require("gears.timer")

local patches = {fix = {}}

-- https://github.com/trip-zip/somewm/issues/628
function patches.fix.emit_unfocus_on_exit()
  client.connect_signal("unmanage", function(c) c:emit_signal("unfocus") end)
end

-- https://github.com/trip-zip/somewm/issues/626
function patches.fix.fix_border_gap()
  local delayed_arrange = {}
  local arrange_lock = false

  local function get_screen(s)
    return s and screen[s]
  end

  function awful.layout.arrange(screen)
    screen = get_screen(screen)
    if not screen or delayed_arrange[screen] then
      return
    end
    delayed_arrange[screen] = true

    timer.delayed_call(function()
      if not screen.valid then
        -- Screen was removed
        delayed_arrange[screen] = nil
        return
      end
      if arrange_lock then return end
      arrange_lock = true

      -- protected call to ensure that arrange_lock will be reset
      protected_call(function()
        local p = awful.layout.parameters(nil, screen)

        local useless_gap = p.useless_gap

        p.geometries = setmetatable({}, {__mode = "k"})
        awful.layout.get(screen).arrange(p)

        for c, g in pairs(p.geometries) do
          g.width = math.max(1, g.width - useless_gap * 2)
          g.height = math.max(1, g.height - useless_gap * 2)
          g.x = g.x + useless_gap
          g.y = g.y + useless_gap
          c:geometry(g)
        end
      end)
      arrange_lock = false
      delayed_arrange[screen] = nil

      screen:emit_signal("arrange")
    end)
  end
end

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
