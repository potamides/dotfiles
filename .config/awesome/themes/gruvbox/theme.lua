-------------------------------------------------------------------------------
-- gruvbox awesome theme
-------------------------------------------------------------------------------

local awful = require("awful")
local usurface = require("utils.surface")
local dpi = require("beautiful.xresources").apply_dpi
local theme_assets = require("beautiful.theme_assets")
local icon_utils = require("utils.icon")

local theme_path = awful.util.getdir("config") .. "/themes/gruvbox/"
local theme = {}

theme.font       = "sans-serif 11"
theme.icon_theme = icon_utils.convert_theme("Gruvbox-Plus-Dark")

-- crop to size where wallpaper repeats itself
theme.wallpaper = usurface.crop(theme_path .. "wallpaper.png", 384, 0, 1920, 1080)

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
theme.bg_urgent  = theme.bg0_h
theme.bg_systray = theme.bg0_h

theme.fg_normal  = theme.fg4
theme.fg_focus   = theme.fg1
theme.fg_urgent  = theme.lightorange

--  Borders
theme.useless_gap       = dpi(10)
theme.gap_single_client = true
theme.border_width      = dpi(3)
theme.border_normal     = theme.bg2
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
theme.taglist_bg_hover    = theme.bg2
theme.taglist_font        = "sans-serif:weight=heavy 13"

-- Menu
theme.menu_height       = dpi(16)
theme.menu_width        = dpi(140)
theme.menu_border_width = dpi(3)
theme.menu_fg_normal    = theme.fg1
theme.menu_bg_focus     = theme.bg2
theme.menu_border_color = theme.bg0_h

-- Menu of clients
theme.clientsmenu_width        = dpi(640)
theme.clientsmenu_border_color = theme.bg4

-- hotkeys popup
theme.hotkeys_border_color = theme.bg4

-- Menubar
theme.menubar_border_width = theme.border_width

-- Notifications
theme.notification_opacity   = 0.75
theme.notification_icon_size = 32

-- Calendar
theme.calendar_year_fg_color        = theme.fg1
theme.calendar_month_fg_color       = theme.fg1
theme.calendar_year_header_fg_color = theme.fg1
theme.calendar_header_fg_color      = theme.fg1
theme.calendar_weekday_fg_color     = theme.fg1
theme.calendar_weeknumber_fg_color  = theme.fg1
theme.calendar_normal_fg_color      = theme.fg1
theme.calendar_focus_fg_color       = theme.fg1

theme.calendar_year_border_color        = theme.bg0_h
theme.calendar_month_border_color       = theme.bg0_h
theme.calendar_year_header_border_color = theme.bg0_h
theme.calendar_header_border_color      = theme.bg0_h
theme.calendar_weekday_border_color     = theme.bg0_h
theme.calendar_weeknumber_border_color  = theme.bg0_h
theme.calendar_normal_border_color      = theme.bg0_h
theme.calendar_focus_border_color       = theme.bg0_h

-- Custom sizes
theme.pgram_slope      = dpi(10)
theme.gap              = dpi(4)
theme.big_gap          = theme.gap + theme.pgram_slope
theme.med_gap          = theme.gap + 0.5 * theme.pgram_slope
theme.small_gap        = theme.gap / 2
theme.big_negative_gap = -theme.pgram_slope
theme.negative_gap     = theme.big_negative_gap + theme.gap
theme.wibar_height     = dpi(21)
theme.titlebar_height  = dpi(20)

-- Systray
theme.systray_icon_spacing = theme.gap

-- All Widgets
theme.widget_markup = "<span weight='heavy' color=%q>%s</span>"

-- Playback Status Widget
theme.playback_width     = dpi(200)
theme.playback_bg_normal = theme.bg1
theme.playback_bg_hover  = theme.bg2
theme.playback_bg_press  = theme.bg3

-- Layout
theme.layout_tile       = theme_path .. "layouts/tile.svg"
theme.layout_tileleft   = theme_path .. "layouts/tileleft.svg"
theme.layout_tilebottom = theme_path .. "layouts/tilebottom.svg"
theme.layout_tiletop    = theme_path .. "layouts/tiletop.svg"
theme.layout_fairv      = theme_path .. "layouts/fair.svg"
theme.layout_fairh      = theme_path .. "layouts/fair.svg"
theme.layout_spiral     = theme_path .. "layouts/spiral.svg"
theme.layout_dwindle    = theme_path .. "layouts/spiral.svg"
theme.layout_max        = theme_path .. "layouts/max.svg"
theme.layout_fullscreen = theme_path .. "layouts/fullscreen.svg"
theme.layout_magnifier  = theme_path .. "layouts/magnifier.svg"
theme.layout_floating   = theme_path .. "layouts/floating.svg"
theme.layout_cornernw   = theme_path .. "layouts/cornernw.svg"
theme.layout_cornerne   = theme_path .. "layouts/cornerne.svg"
theme.layout_cornersw   = theme_path .. "layouts/cornersw.svg"
theme.layout_cornerse   = theme_path .. "layouts/cornerse.svg"
theme.layout_centerwork = theme_path .. "layouts/centerwork.svg"

-- Titlebar
theme.titlebar_ontop_button_focus_active    = theme_path .. "titlebar/ontop_select.svg"
theme.titlebar_ontop_button_normal_active   = theme_path .. "titlebar/ontop_select.svg"
theme.titlebar_ontop_button_focus_inactive  = theme_path .. "titlebar/ontop_unselect.svg"
theme.titlebar_ontop_button_normal_inactive = theme_path .. "titlebar/ontop_unselect.svg"

theme.titlebar_sticky_button_focus_active    = theme_path .. "titlebar/sticky_select.svg"
theme.titlebar_sticky_button_normal_active   = theme_path .. "titlebar/sticky_select.svg"
theme.titlebar_sticky_button_focus_inactive  = theme_path .. "titlebar/sticky_unselect.svg"
theme.titlebar_sticky_button_normal_inactive = theme_path .. "titlebar/sticky_unselect.svg"

theme.titlebar_maximized_button_focus_active    = theme_path .. "titlebar/maximized_select.svg"
theme.titlebar_maximized_button_normal_active   = theme_path .. "titlebar/maximized_select.svg"
theme.titlebar_maximized_button_focus_inactive  = theme_path .. "titlebar/maximized_unselect.svg"
theme.titlebar_maximized_button_normal_inactive = theme_path .. "titlebar/maximized_unselect.svg"

theme.titlebar_floating_button_focus_active    = theme_path .. "titlebar/floating_select.svg"
theme.titlebar_floating_button_normal_active   = theme_path .. "titlebar/floating_select.svg"
theme.titlebar_floating_button_focus_inactive  = theme_path .. "titlebar/floating_unselect.svg"
theme.titlebar_floating_button_normal_inactive = theme_path .. "titlebar/floating_unselect.svg"

-- Icons
theme.awesome_icon = theme_assets.awesome_icon(theme.menu_height, theme.bg_focus, theme.fg_focus)
theme.archlinux_icon  = theme_path .. "bar/archlinux.svg"

return theme

