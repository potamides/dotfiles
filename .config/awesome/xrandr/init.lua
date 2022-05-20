-- Separating Multiple Monitor functions as a separeted module
-- slightly modified version of https://awesomewm.org/recipes/xrandr.lua

local gtable  = require("gears.table")
local spawn  = require("awful.spawn")
local naughty = require("naughty")
local beautiful = require("beautiful")

local xrandr = {
  state = { cid = nil },
  position = "below"
}

-- Get active outputs
local function outputs()
  local _outputs = {}
  local handle = io.popen("xrandr -q --current")

  if handle then
    for line in handle:lines() do
      local output = line:match("^([%w-]+) connected ")
      if output then
        _outputs[#_outputs + 1] = output
      end
    end
    handle:close()
  end

  return _outputs
end

local function arrange(out)
  -- We need to enumerate all permutations of horizontal outputs.

  local choices  = {}
  local previous = { {} }
  for _ = 1, #out do
    -- Find all permutation of length `i`: we take the permutation of length
    -- `i-1` and for each of them, we create new permutations by adding each
    -- output at the end of it if it is not already present.
    local new = {}
    for _, p in pairs(previous) do
      for _, o in pairs(out) do
        if not gtable.hasitem(p, o) then
          new[#new + 1] = gtable.join(p, {o})
        end
      end
    end
    choices = gtable.join(choices, new)
    previous = new
  end

  return choices
end

-- Build available choices
local function menu()
  local _menu = {}
  local out = outputs()
  local choices = arrange(out)

  for _, choice in pairs(choices) do
    local cmd = "xrandr"
    -- Enabled outputs
    for i, o in pairs(choice) do
      cmd = cmd .. " --output " .. o .. " --auto"
      if i > 1 then
        cmd = cmd .. string.format(" --%s ", xrandr.position) .. choice[i-1]
      else
        cmd = cmd .. " --primary"
      end
    end
    -- Disabled outputs
    for _, o in pairs(out) do
      if not gtable.hasitem(choice, o) then
        cmd = cmd .. " --output " .. o .. " --off"
      end
    end

    local label = ""
    if #choice == 1 then
      label = 'Only <span weight="bold">' .. choice[1] .. '</span>'
    else
      for i, o in pairs(choice) do
        if i > 1 then label = label .. " + " end
        label = label .. '<span weight="bold">' .. o .. '</span>'
      end
    end

    _menu[#_menu + 1] = { label, cmd }
  end

  return _menu
end

local function naughty_destroy_callback(reason)
  if reason == naughty.notificationClosedReason.expired or
    reason == naughty.notificationClosedReason.dismissedByUser then
   local action = xrandr.state.index and xrandr.state.menu[xrandr.state.index - 1][2]
   if action then
    spawn(action, false)
    xrandr.state.index = nil
   end
  end
end

function xrandr.show()
  -- Build the list of choices
  if not xrandr.state.index then
    xrandr.state.menu = menu()
    xrandr.state.index = 1
  end

  -- Select one and display the appropriate notification
  local label
  local next  = xrandr.state.menu[xrandr.state.index]
  xrandr.state.index = xrandr.state.index + 1

  if not next then
    label = "Keep the current configuration"
    xrandr.state.index = nil
  else
    label = next[1]
  end
  xrandr.state.cid = naughty.notify({
    text        = label,
    icon        = "/usr/share/icons/" .. beautiful.icon_theme .. "/32x32/devices/display.svg",
    timeout     = 4,
    screen      = mouse.screen,
    replaces_id = xrandr.state.cid,
    destroy     = naughty_destroy_callback
  }).id
end

return xrandr
