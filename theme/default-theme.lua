local gears = require('gears')
local beautiful = require('beautiful')

local dpi = require('beautiful').xresources.apply_dpi

local _, package_path = ...
if not package_path then
  package_path = string.sub(debug.getinfo(1, 'S').source, 2)
end
local theme_dir = package_path:match('(.*/)')

local titlebar_theme = 'stoplight'
local titlebar_icon_path = theme_dir .. '/icons/titlebar/' .. titlebar_theme ..
                             '/'
local tip = titlebar_icon_path

local theme = {}
theme.icons = theme_dir .. '/icons/'

-- Font
theme.font = 'URW Gothic'
theme.font_bold = theme.font .. ' Bold'
theme.font_heavy = theme.font .. ' Heavy'
-- Noto Sans Grantha
-- Menu icon theme
-- theme.icon_theme = 'breeze'

theme.dir = theme_dir

theme.icons = theme.dir .. '/icons/'
theme.accent = theme.system_blue_dark

theme.accent = '#6498EF'
-- Foreground

theme.title_font = 'SF Pro Text Bold 14'

theme.fg_normal = '#ffffffde'
theme.fg_focus = '#e4e4e4'
theme.fg_urgent = '#CC9393'

theme.bat_fg_critical = '#232323'
theme.background = '#00000066'

theme.bg_normal = theme.background
theme.bg_focus = '#5a5a5a'
theme.bg_urgent = '#3F3F3F'

theme.margin_size = dpi(6)
theme.margin_hover_diff = dpi(6)
theme.transparent = '#00000000'

-- System tray

theme.bg_systray = theme.background
theme.systray_icon_spacing = dpi(9)

-- Titlebar

theme.titlebar_size = dpi(27)
theme.titlebar_button_margin = dpi(6)
theme.titlebar_button_spacing = dpi(3)
theme.titlebar_pos = 'left'
theme.titlebar_button_pos = 'top'
theme.titlebar_enabled = true
theme.border_width = dpi(0)
theme.wibar_border_width = dpi(0)
theme.titlebar_bg_focus = '#000000' .. '66'
theme.titlebar_bg_normal = '#000000' .. '66'
theme.titlebar_fg_focus = '#000000' .. '66'
theme.titlebar_fg_normal = '#000000' .. '66'

-- Close Button
theme.titlebar_close_button_normal = tip .. 'close_normal.svg'
theme.titlebar_close_button_focus = tip .. 'close_focus.svg'

-- Minimize Button
theme.titlebar_minimize_button_normal = tip .. 'minimize_normal.svg'
theme.titlebar_minimize_button_focus = tip .. 'minimize_focus.svg'

-- Ontop Button
theme.titlebar_ontop_button_normal_inactive = tip .. 'ontop_normal_inactive.svg'
theme.titlebar_ontop_button_focus_inactive = tip .. 'ontop_focus_inactive.svg'
theme.titlebar_ontop_button_normal_active = tip .. 'ontop_normal_active.svg'
theme.titlebar_ontop_button_focus_active = tip .. 'ontop_focus_active.svg'

-- Sticky Button
theme.titlebar_sticky_button_normal_inactive =
  tip .. 'sticky_normal_inactive.svg'
theme.titlebar_sticky_button_focus_inactive = tip .. 'sticky_focus_inactive.svg'
theme.titlebar_sticky_button_normal_active = tip .. 'sticky_normal_active.svg'
theme.titlebar_sticky_button_focus_active = tip .. 'sticky_focus_active.svg'

-- Floating Button
theme.titlebar_floating_button_normal_inactive =
  tip .. 'floating_normal_inactive.svg'
theme.titlebar_floating_button_focus_inactive =
  tip .. 'floating_focus_inactive.svg'
theme.titlebar_floating_button_normal_active =
  tip .. 'floating_normal_active.svg'
theme.titlebar_floating_button_focus_active = tip .. 'floating_focus_active.svg'

-- Maximized Button
theme.titlebar_maximized_button_normal_inactive =
  tip .. 'maximized_normal_inactive.svg'
theme.titlebar_maximized_button_focus_inactive =
  tip .. 'maximized_focus_inactive.svg'
theme.titlebar_maximized_button_normal_active =
  tip .. 'maximized_normal_active.svg'
theme.titlebar_maximized_button_focus_active =
  tip .. 'maximized_focus_active.svg'

-- Hovered Close Button
theme.titlebar_close_button_normal_hover = tip .. 'close_normal_hover.svg'
theme.titlebar_close_button_focus_hover = tip .. 'close_focus_hover.svg'

-- Hovered Minimize Buttin
theme.titlebar_minimize_button_normal_hover = tip .. 'minimize_normal_hover.svg'
theme.titlebar_minimize_button_focus_hover = tip .. 'minimize_focus_hover.svg'

-- Hovered Ontop Button
theme.titlebar_ontop_button_normal_inactive_hover =
  tip .. 'ontop_normal_inactive_hover.svg'
theme.titlebar_ontop_button_focus_inactive_hover =
  tip .. 'ontop_focus_inactive_hover.svg'
theme.titlebar_ontop_button_normal_active_hover =
  tip .. 'ontop_normal_active_hover.svg'
theme.titlebar_ontop_button_focus_active_hover =
  tip .. 'ontop_focus_active_hover.svg'

-- Hovered Sticky Button
theme.titlebar_sticky_button_normal_inactive_hover =
  tip .. 'sticky_normal_inactive_hover.svg'
theme.titlebar_sticky_button_focus_inactive_hover =
  tip .. 'sticky_focus_inactive_hover.svg'
theme.titlebar_sticky_button_normal_active_hover =
  tip .. 'sticky_normal_active_hover.svg'
theme.titlebar_sticky_button_focus_active_hover =
  tip .. 'sticky_focus_active_hover.svg'

-- Hovered Floating Button
theme.titlebar_floating_button_normal_inactive_hover =
  tip .. 'floating_normal_inactive_hover.svg'
theme.titlebar_floating_button_focus_inactive_hover =
  tip .. 'floating_focus_inactive_hover.svg'
theme.titlebar_floating_button_normal_active_hover =
  tip .. 'floating_normal_active_hover.svg'
theme.titlebar_floating_button_focus_active_hover =
  tip .. 'floating_focus_active_hover.svg'

-- Hovered Maximized Button
theme.titlebar_maximized_button_normal_inactive_hover =
  tip .. 'maximized_normal_inactive_hover.svg'
theme.titlebar_maximized_button_focus_inactive_hover =
  tip .. 'maximized_focus_inactive_hover.svg'
theme.titlebar_maximized_button_normal_active_hover =
  tip .. 'maximized_normal_active_hover.svg'
theme.titlebar_maximized_button_focus_active_hover =
  tip .. 'maximized_focus_active_hover.svg'

-- UI Groups

theme.groups_title_bg = '#ffffff' .. '15'
-- theme.groups_bg = '#ffffff' .. '10'
theme.groups_bg = '#ffffff' .. '10'
theme.groups_radius = dpi(10)

-- Client Decorations

-- Borders
if theme.titlebar_enabled then
  theme.border_focus = theme.background
else
  theme.border_focus = '#666666' .. '30'
end
theme.border_normal = theme.background
theme.border_marked = '#CC9393'
theme.border_radius = dpi(10)

-- Decorations
theme.client_radius = dpi(6)
theme.useless_gap = 5

-- Menu
theme.menu_font = 'SF Pro Text Regular 11'
theme.menu_submenu = '' -- ➤

theme.menu_height = dpi(24)
theme.menu_width = dpi(200)
theme.menu_border_width = dpi(12)

theme.menu_bg_normal = '#00000023'
theme.menu_fg_normal = '#ffffff'
theme.menu_fg_focus = '#ffffff'
theme.menu_bg_focus = theme.accent
theme.menu_border_color = '#00000044'

-- Tooltips

theme.tooltip_bg = theme.background
theme.tooltip_border_color = theme.transparent
theme.tooltip_border_width = 0
theme.tooltip_gaps = dpi(5)
theme.tooltip_shape = function(cr, w, h) gears.shape.rectangle(cr, w, h) end

-- Separators

theme.separator_color = '#f2f2f244'

-- Layoutbox icons

theme.layout_max = theme.icons .. 'layouts/max.svg'
theme.layout_tile = theme.icons .. 'layouts/tile.svg'
theme.layout_tilebottom = theme.icons .. 'layouts/tilebottom.svg'
theme.layout_dwindle = theme.icons .. 'layouts/dwindle.svg'
theme.layout_floating = theme.icons .. 'layouts/floating.svg'
theme.layout_fairh = theme.icons .. 'layouts/fairh.svg'

-- Taglist

theme.taglist_bg_empty = '#000000' .. '00'
theme.taglist_bg_occupied = '#000000' .. '00'
theme.taglist_bg_urgent = '#000000' .. '00'
theme.taglist_bg_focus = '#000000' .. '00'
theme.taglist_spacing = dpi(0)

-- Tasklist

theme.tasklist_font = 'SF Pro Text Regular 10'
theme.tasklist_bg_minimize = '#000000' .. '33'
theme.tasklist_bg_normal = '#777777' .. '66'
theme.tasklist_bg_urgent = '#E91E63' .. '99'
theme.tasklist_bg_focus = '#aaaaaa' .. '80'
theme.tasklist_fg_focus = '#DDDDDD'
theme.tasklist_fg_urgent = '#ffffff'
theme.tasklist_fg_normal = '#AAAAAA'

-- Popup
theme.popup_bg = '#000000' .. '00'

-- Notification

theme.notification_bg1 = '#00000040'
theme.notification_bg2 = '#00000040'
theme.notification_position = 'top_right'
theme.notification_bg = theme.background .. '99'
theme.notification_margin = 2 * theme.useless_gap
theme.notification_type = 'notification' -- use "dock" for no blur "notification" for blur
theme.notification_border_width = dpi(0)
theme.notification_border_color = theme.transparent
theme.notification_spacing = dpi(0)
theme.notification_icon_resize_strategy = 'center'
theme.notification_icon_size = dpi(70)
_G.dont_disturb = true

-- Client Snap Theme

theme.snap_bg = theme.background
theme.snap_shape = gears.shape.rectangle
theme.snap_border_width = dpi(15)

-- Hotkey popup

theme.hotkeys_font = 'SF Pro Text Bold'
theme.hotkeys_description_font = 'SF Pro Text Regular Regular'
theme.hotkeys_bg = theme.background
theme.hotkeys_group_margin = dpi(20)

-- Main panel
theme.panel_height = 35
theme.panel_width = 890
theme.panel_desktop_width = 840
theme.panel_laptop_width = 1000
theme.panel_bg = '#000000' .. '00'
theme.panel_radius = dpi(0)
theme.panel_widget_border_width = dpi(0)
theme.panel_widget_border_color = '#aaaaaa' .. '66'
theme.panel_widget_bg_color = '#000000' .. '00'
theme.panel_widget_radius = dpi(0)
theme.panel_padding = 2
theme.panel_blur_type = 'dock' -- use "dock" for no blur, "panel" for blur

-- Second small panel
-- small heigt meeans the increase call back is necessary so one can read it
theme.small_panel_height = 17
theme.small_panel_width = 1920
theme.small_panel_desktop_width = 1920
theme.small_panel_laptop_width = 1920
theme.small_panel_bg = '#000000' .. '66'
theme.small_panel_radius = 0
theme.small_panel_widget_border_width = dpi(0)
theme.small_panel_widget_border_color = '#aaaaaa' .. '66'
theme.small_panel_widget_bg_color = '#000000' .. '66'
theme.small_panel_widget_radius = dpi(3)
theme.small_panel_padding = dpi(4)
theme.small_panel_blur_type = 'panel' -- use "dock" for no blur, "panel" for blur

-- Popup

theme.osd_width = dpi(350)
theme.osd_height = dpi(200)

return theme
