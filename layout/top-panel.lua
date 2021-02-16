local panel_builder = require('module.panel-builder')
local beautiful = require('beautiful')
local callbacks = require('widget.callbacks')

local status_panel = function(s)
  io.stderr:write('Building additional small panel\n')
  local args = {
    screen = s,
    orientation = 'horizontal',
    position = 'top',
    blur_type = beautiful.small_panel_blur_type,
    panel_height = beautiful.small_panel_height,
    panel_width = beautiful.small_panel_width,
    panel_bg = beautiful.small_panel_bg,
    fg_normal = beautiful.small_fg_normal,
    panel_radius = beautiful.panel_radius,
    callback = callbacks.background,
    panel_padding = beautiful.small_panel_padding
  }
  local panel = panel_builder.build_single_panel(
    args, {
      left_widgets = {'app-search-toggler', 'tasklist'},
      middle_widgets = {'clock'},
      right_widgets = {
        'network-widget', 'battery-widget', 'end-session',
        'notification-panel-toggler'
      }
    })
  return panel
end

return status_panel

