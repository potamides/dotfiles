local unpack = unpack or table.unpack -- luacheck: globals unpack (compatibility with Lua 5.1)
local timer = {}

--- Call the given function at the end of the next main loop iteration
function timer.next_main_loop(callback, ...)
  local args, next_main_loop = {...}, false
  local function wait_next_main_loop()
    if next_main_loop then
      callback(unpack{args})
      awesome.disconnect_signal("refresh", wait_next_main_loop)
    else
      next_main_loop = true
    end
  end
  awesome.connect_signal("refresh", wait_next_main_loop)
end

return timer
