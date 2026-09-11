-- Based on https://github.com/lcpz/lain/blob/master/layout/centerwork.lua

local layout = {
  centerwork = {
    name = "centerwork",
  }
}

function layout.centerwork.arrange(p)
  local t   = p.tag or screen[p.screen].selected_tag
  local wa  = p.workarea
  local cls = p.clients

  if #cls == 0 then return end

  local g = {}

  -- Main column, fixed width and height
  local mwfact          = t.master_width_factor
  local mainwid         = math.floor(wa.width * mwfact)
  local slavewid        = wa.width - mainwid
  local slaveLwid       = math.floor(slavewid / 2)
  local slaveRwid       = slavewid - slaveLwid
  local nbrFirstSlaves  = math.floor(#cls / 2)
  local nbrSecondSlaves = math.floor((#cls - 1) / 2)

  local slaveFirstDim, slaveSecondDim = 0, 0

  if nbrFirstSlaves  > 0 then slaveFirstDim  = math.floor(wa.height / nbrFirstSlaves) end
  if nbrSecondSlaves > 0 then slaveSecondDim = math.floor(wa.height / nbrSecondSlaves) end

  g.height = wa.height
  g.width  = mainwid

  g.x = wa.x + slaveLwid
  g.y = wa.y

  g.width  = math.max(g.width, 1)
  g.height = math.max(g.height, 1)

  p.geometries[cls[1]] = g

  -- Auxiliary clients
  if #cls <= 1 then return end
  for i = 2, #cls do
    g = {}
    local idxChecker, dimToAssign

    local rowIndex = math.floor(i/2)

    if i % 2 == 0 then -- left slave
      g.x     = wa.x
      g.y     = wa.y + (rowIndex - 1) * slaveFirstDim
      g.width = slaveLwid

      idxChecker, dimToAssign = nbrFirstSlaves, slaveFirstDim
    else -- right slave
      g.x     = wa.x + slaveLwid + mainwid
      g.y     = wa.y + (rowIndex - 1) * slaveSecondDim
      g.width = slaveRwid

      idxChecker, dimToAssign = nbrSecondSlaves, slaveSecondDim
    end

    -- if last slave in row, use remaining space for it
    if rowIndex == idxChecker then
      g.height = wa.y + wa.height - g.y
    else
      g.height = dimToAssign
    end

    g.width  = math.max(g.width, 1)
    g.height = math.max(g.height, 1)

    p.geometries[cls[i]] = g
  end
end

function layout.centerwork.mouse_resize_handler(c)
  local wa     = c.screen.workarea
  local mwfact = c.screen.selected_tag.master_width_factor
  local g      = c:geometry()
  local offset = 0
  local cursor = "cross"

  local corner_coords

  if g.height + 15 >= wa.height then
    offset = g.height * .5
    cursor = "sb_h_double_arrow"
  elseif not (g.y + g.height + 15 > wa.y + wa.height) then
    offset = g.height
  end
  corner_coords = { x = wa.x + wa.width * (1 - mwfact) / 2, y = g.y + offset }

  mouse.coords(corner_coords)

  local prev_coords = {}

  mousegrabber.run(function(_mouse)
    if not c.valid then return false end
    for _, v in ipairs(_mouse.buttons) do
      if v then
        prev_coords = { x = _mouse.x, y = _mouse.y }
        local new_mwfact = 1 - (_mouse.x - wa.x) / wa.width * 2
        c.screen.selected_tag.master_width_factor = math.min(math.max(new_mwfact, 0.01), 0.99)
        return true
      end
    end
    return prev_coords.x == _mouse.x and prev_coords.y == _mouse.y
  end, cursor)
end

return layout
