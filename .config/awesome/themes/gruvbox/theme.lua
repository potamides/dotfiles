-------------------------------------------------------------------------------
-- gruvbox awesome theme
-------------------------------------------------------------------------------

local awful = require("awful")
local theme_assets = require("beautiful.theme_assets")
local themes_path = awful.util.getdir("config").."/themes/"
local dpi = require("beautiful.xresources").apply_dpi



local theme = {}

theme.archlinux_icon  = themes_path .. "gruvbox/bar/archlinux.svg"
theme.font            = "DejaVu Sans 11"
theme.revelation_font = "SauceCodePro Nerd Font 20"
theme.icon_theme      = "Papirus-Dark"

function theme.wallpaper(s)
  -- the screen where conky is on
  if s.geometry.x == 0 and s.geometry.y == 0 then
    return themes_path .. "gruvbox/wall_primary.png"
  else
    return themes_path .. "gruvbox/wall_secondary.png"
  end
end

-- Dark Gruvbox Colors
theme.lightred    = "#fb4934"
theme.red         = "#cc241d"
theme.lightorange = "#fe8019"
theme.orange      = "#d65d0e"
theme.lightyellow = "#fabd2f"
theme.yellow      = "#d79921"
theme.lightgreen  = "#b8bb26"
theme.green       = "#98971a"
theme.lightaqua   = "#8ec07c"
theme.aqua        = "#689d6a"
theme.lightblue   = "#83a598"
theme.blue        = "#458588"
theme.lightpurple = "#d3869b"
theme.purple      = "#b16286"
theme.fg0         = "#fbf1c7"
theme.fg1         = "#ebdbb2"
theme.fg2         = "#d5c4a1"
theme.fg3         = "#bdae93"
theme.fg4         = "#a89984"
theme.gray        = "#928374"
theme.bg4         = "#7c6f64"
theme.bg3         = "#665c54"
theme.bg2         = "#504945"
theme.bg1         = "#3c3836"
theme.bg0_s       = "#32302f"
theme.bg0         = "#282828"
theme.bg0_h       = "#1d2021"

-- Colors
theme.bg_normal  = theme.bg0_h
theme.bg_focus   = theme.bg1
theme.bg_urgent  = theme.bg_normal
theme.bg_systray = theme.bg_normal

theme.fg_normal  = theme.fg4
theme.fg_focus   = theme.fg1
theme.fg_urgent  = theme.lightorange

--  Borders
theme.useless_gap       = 0
theme.gap_single_client = false
theme.border_width      = dpi(3)
theme.border_normal     = theme.bg0_h
theme.border_focus      = theme.bg4
theme.border_marked     = theme.lightpurple

-- Titlebars
theme.titlebar_bg_focus  = theme.bg0_s
theme.titlebar_fg_focus  = theme.bg0_s
theme.titlebar_fg_normal = theme.bg0_s
theme.titlebar_bg_normal = theme.bg0_s

-- Taglist
theme.taglist_fg_empty    = theme.bg3
theme.taglist_fg_occupied = theme.fg4
theme.taglist_fg_focus    = theme.bg0
theme.taglist_fg_urgent   = theme.bg0
theme.taglist_fg_volatile = theme.bg0
theme.taglist_bg_focus    = theme.lightaqua
theme.taglist_bg_urgent   = theme.lightorange
theme.taglist_bg_occupied = theme.bg1
theme.taglist_bg_volatile = theme.lightpurple
theme.taglist_bg_empty    = theme.bg1
theme.taglist_font        = "DejaVu Sans Bold 18"

-- Menu
theme.menu_height       = dpi(16)
theme.menu_width        = dpi(140)
theme.menu_border_width = dpi(10)
theme.menu_fg_normal    = theme.fg_focus
theme.menu_bg_focus     = theme.bg2
theme.menu_border_color = theme.bg_normal

-- Menubar
theme.menubar_border_width = theme.border_width

-- Notifications
theme.notification_opacity = 0.75

-- Calendar
theme.calendar_year_fg_color        = theme.fg_focus
theme.calendar_month_fg_color       = theme.fg_focus
theme.calendar_year_header_fg_color = theme.fg_focus
theme.calendar_header_fg_color      = theme.fg_focus
theme.calendar_weekday_fg_color     = theme.fg_focus
theme.calendar_weeknumber_fg_color  = theme.fg_focus
theme.calendar_normal_fg_color      = theme.fg_focus
theme.calendar_focus_fg_color       = theme.fg_focus

-- Custom sizes
theme.small_gap        = dpi(2)
theme.gap              = dpi(4)
theme.big_gap          = dpi(14)
theme.negative_gap     = dpi(-6)
theme.big_negative_gap = dpi(-10)
theme.wibar_height     = dpi(21)
theme.titlebar_height  = dpi(20)

-- Systray
theme.systray_icon_spacing = theme.gap

-- Layout
theme.layout_tile       = themes_path .. "gruvbox/layouts/tile.svg"
theme.layout_tileleft   = themes_path .. "gruvbox/layouts/tileleft.svg"
theme.layout_tilebottom = themes_path .. "gruvbox/layouts/tilebottom.svg"
theme.layout_tiletop    = themes_path .. "gruvbox/layouts/tiletop.svg"
theme.layout_fairv      = themes_path .. "gruvbox/layouts/fair.svg"
theme.layout_fairh      = themes_path .. "gruvbox/layouts/fair.svg"
theme.layout_spiral     = themes_path .. "gruvbox/layouts/spiral.svg"
theme.layout_dwindle    = themes_path .. "gruvbox/layouts/spiral.svg"
theme.layout_max        = themes_path .. "gruvbox/layouts/max.svg"
theme.layout_fullscreen = themes_path .. "gruvbox/layouts/fullscreen.svg"
theme.layout_magnifier  = themes_path .. "gruvbox/layouts/magnifier.svg"
theme.layout_floating   = themes_path .. "gruvbox/layouts/floating.svg"
theme.layout_cornernw   = themes_path .. "gruvbox/layouts/cornernw.svg"
theme.layout_cornerne   = themes_path .. "gruvbox/layouts/cornerne.svg"
theme.layout_cornersw   = themes_path .. "gruvbox/layouts/cornersw.svg"
theme.layout_cornerse   = themes_path .. "gruvbox/layouts/cornerse.svg"

-- Titlebar
theme.titlebar_ontop_button_focus_active    = themes_path .. "gruvbox/titlebar/ontop_select.svg"
theme.titlebar_ontop_button_normal_active   = themes_path .. "gruvbox/titlebar/ontop_select.svg"
theme.titlebar_ontop_button_focus_inactive  = themes_path .. "gruvbox/titlebar/ontop_unselect.svg"
theme.titlebar_ontop_button_normal_inactive = themes_path .. "gruvbox/titlebar/ontop_unselect.svg"

theme.titlebar_sticky_button_focus_active    = themes_path .. "gruvbox/titlebar/sticky_select.svg"
theme.titlebar_sticky_button_normal_active   = themes_path .. "gruvbox/titlebar/sticky_select.svg"
theme.titlebar_sticky_button_focus_inactive  = themes_path .. "gruvbox/titlebar/sticky_unselect.svg"
theme.titlebar_sticky_button_normal_inactive = themes_path .. "gruvbox/titlebar/sticky_unselect.svg"

theme.titlebar_maximized_button_focus_active    = themes_path .. "gruvbox/titlebar/maximized_select.svg"
theme.titlebar_maximized_button_normal_active   = themes_path .. "gruvbox/titlebar/maximized_select.svg"
theme.titlebar_maximized_button_focus_inactive  = themes_path .. "gruvbox/titlebar/maximized_unselect.svg"
theme.titlebar_maximized_button_normal_inactive = themes_path .. "gruvbox/titlebar/maximized_unselect.svg"

theme.titlebar_floating_button_focus_active    = themes_path .. "gruvbox/titlebar/floating_select.svg"
theme.titlebar_floating_button_normal_active   = themes_path .. "gruvbox/titlebar/floating_select.svg"
theme.titlebar_floating_button_focus_inactive  = themes_path .. "gruvbox/titlebar/floating_unselect.svg"
theme.titlebar_floating_button_normal_inactive = themes_path .. "gruvbox/titlebar/floating_unselect.svg"

-- Generate Awesome Icon
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

return theme

