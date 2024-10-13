local colors = {
  black   = 0,
  red     = 1,
  green   = 2,
  yellow  = 3,
  blue    = 4,
  magenta = 5,
  cyan    = 6,
  gray    = 7,
}

local function add_xyz(tbl)
  return vim.tbl_extend("error", tbl, {x=tbl.c, y=tbl.b, z=tbl.a})
end

return {
  normal = add_xyz{
    a = { bg = colors.gray, fg = colors.black },
    b = { bg = colors.black, fg = colors.gray },
    c = { bg = colors.gray, fg = colors.black },
  },
  command = add_xyz{
    a = { bg = colors.gray, fg = colors.black },
    b = { bg = colors.black, fg = colors.gray },
    c = { bg = colors.gray, fg = colors.black },
  },
  insert = add_xyz{
    a = { bg = colors.blue, fg = colors.black },
    b = { bg = colors.black, fg = colors.gray, gui = "bold" },
    c = { bg = colors.gray, fg = colors.black },
  },
  replace = add_xyz{
    a = { bg = colors.cyan, fg = colors.black },
    b = { bg = colors.black, fg = colors.gray, gui = "bold" },
    c = { bg = colors.gray, fg = colors.black },
  },
  terminal = add_xyz{
    a = { bg = colors.green, fg = colors.black },
    b = { bg = colors.black, fg = colors.gray, gui = "bold" },
    c = { bg = colors.gray, fg = colors.black },
  },
  visual = add_xyz{
    a = { bg = colors.yellow, fg = colors.black },
    b = { bg = colors.gray, fg = colors.black },
    c = { bg = colors.black, fg = colors.gray },
  },
  inactive = add_xyz{
    a = { bg = colors.gray, fg = colors.black },
    b = { bg = colors.gray, fg = colors.black },
    c = { bg = colors.gray, fg = colors.black },
  },
}
