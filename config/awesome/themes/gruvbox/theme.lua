-------------------------------------------------------------------------------
-- gruvbox awesome theme
-------------------------------------------------------------------------------
local awful = require("awful")
local themes_path = awful.util.getdir("config").."/themes/"
local dpi = require("beautiful.xresources").apply_dpi



local theme = {}

theme.archlinux_icon  = themes_path .. "gruvbox/bar/archlinux.svg"
theme.wallpaper       = themes_path .. "gruvbox/wall.png"
theme.font            = "DejaVu Sans 11"
theme.revelation_font = "DejaVu Sans Mono 20"

-- Gruvbox Colors
theme.red         = "#cc241d"
theme.lightred    = "#fb4934"
theme.green       = "#98971a"
theme.lightgreen  = "#b8bb26"
theme.yellow      = "#d79921"
theme.lightyellow = "#fabd2f"
theme.blue        = "#458588"
theme.lightblue   = "#83a598"
theme.purple      = "#b16286"
theme.lightpurple = "#d3869b"
theme.aqua        = "#689d6a"
theme.lightaqua   = "#8ec07c"
theme.orange      = "#d65d0e"
theme.lightorange = "#fe8019"
theme.gray_0      = "#a89984"
theme.gra_1       = "#928374"
theme.bg0_h       = "#1d2021"
theme.bg0_s       = "#32302f"
theme.bg0         = "#282828"
theme.bg1         = "#3c3836"
theme.bg2         = "#504945"
theme.bg3         = "#665c54"
theme.bg4         = "#7c6f64"
theme.fg4         = "#a89984"
theme.fg3         = "#bdae93"
theme.fg2         = "#d5c4a1"
theme.fg1         = "#ebdbb2"
theme.fg0         = "#fbf1c7"

-- Colors
theme.bg_normal  = theme.bg0_h
theme.bg_focus   = theme.bg1
theme.bg_urgent  = theme.bg_normal
theme.bg_systray = theme.bg_normal

theme.fg_normal  = theme.fg4
theme.fg_focus   = theme.fg1
theme.fg_urgent  = theme.lightorange

--  Borders
theme.useless_gap       = dpi(0)
theme.gap_single_client = false
theme.border_width      = dpi(2)
theme.border_normal     = theme.bg0_h
theme.border_focus      = theme.bg4
theme.border_marked     = theme.lightpurple

-- Titlebars
theme.titlebar_bg_focus  = theme.bg0_s
theme.titlebar_fg_focus  = theme.bg0_s
theme.titlebar_fg_normal = theme.bg0_s
theme.titlebar_bg_normal = theme.bg0_s

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

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

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height       = dpi(16)
theme.menu_width        = dpi(140)
theme.menu_border_width = dpi(10)
theme.menu_fg_normal    = theme.fg_focus
theme.menu_fg_focus     = theme.bg_normal
theme.menu_bg_focus     = theme.lightaqua
theme.menu_border_color = theme.bg_normal

-- Taglist
--theme.taglist_squares_sel   = themes_path .. "gruvbox/taglist/squarefz.png"
--theme.taglist_squares_unsel = themes_path .. "gruvbox/taglist/squarez.png"
--theme.taglist_squares_resize = "false"

-- notifications
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

-- custom sizes
theme.small_gap        = dpi(2)
theme.gap              = dpi(4)
theme.big_gap          = dpi(14)
theme.negative_gap     = dpi(-6)
theme.big_negative_gap = dpi(-10)
theme.wibar_height     = dpi(21)
theme.titlebar_height  = dpi(20)

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

return theme

