local glib = require("lgi").GLib
local gfile = require("lgi").Gio.File

local icons = {}

local function iterate_children(dir)
  local children = dir:enumerate_children('standard', "NONE")
  return function() return children:iterate() end
end

local function target_dir(icon_theme)
  return gfile.new_for_path(glib.build_filenamev{glib.get_user_data_dir(), "icons", icon_theme})
end

-- Synchronously convert icon themes from CATEGORY/SIZExSIZE/ICONNAME.EXT to
-- SIZExSIZE/CATEGORY/ICONNAME.EXT, i.e., a format that awesome supports. Also
-- see https://github.com/awesomeWM/awesome/issues/3449
function icons.convert_theme(icon_theme)
  local src_dir = gfile.new_for_path(glib.build_filenamev{"/usr/share/icons", icon_theme})
  local tgt_dir = target_dir(icon_theme)

  if src_dir:query_exists() and not tgt_dir:query_exists() then
    for _, cat in iterate_children(src_dir) do
      if cat:query_file_type{} == "DIRECTORY" then
        for _, size in iterate_children(cat) do
          local tgt_cat = tgt_dir:get_child(size:get_basename()):get_child(cat:get_basename())
          tgt_cat:make_directory_with_parents()

          for _, icon in iterate_children(size) do
            tgt_cat:get_child(icon:get_basename()):make_symbolic_link(icon:get_path())
          end
        end
      else
        tgt_dir:get_child(cat:get_basename()):make_symbolic_link(cat:get_path())
      end
    end
  end

  return icon_theme
end

-- Asynchronously spawns this file in a standalone interpreter to do the slow
-- conversion off the compositor thread.
function icons.convert_theme_async(icon_theme)
  local spawn = require("awful.spawn")
  local gfs = require("gears.filesystem")

  if not target_dir(icon_theme):query_exists() then
    local path_to_file = glib.build_filenamev{
      gfs.get_configuration_dir(), "utils", "icon.lua"
    }
    local interp = jit and "luajit" or "lua"
    spawn.easy_async({interp, path_to_file, icon_theme}, awesome.restart)
  end

  return icon_theme
end

-- modulino is executed when this file is run by a standalone interpreter
if not awesome and arg and arg[1] then
  icons.convert_theme(arg[1])
  return
end

return icons
