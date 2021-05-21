local panel_builder = require('module.panel-builder')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi
local callbacks = require('widget.callbacks')
local wibox = require('wibox')

local taglist = require('widget.taglist')
taglist.show_current_client = true

local status_panel = function(s)
  io.stderr:write('Building status panel\n')
  local args = {
    screen = s,
    orientation = 'horizontal',
    position = 'bottom',
    callback = callbacks.zoom
  }
  local sep = 'separator'
  local panel = panel_builder.build_single_panel(
    args, {
      left_widgets = {nil},
      middle_widgets = {
        'app-search-toggler', sep, 'taglist', sep, 'network-widget',
        'clock', sep, 'notification-panel-toggler',
        'battery-widget', 'end-session', 'layout'
      },
      right_widgets = {nil}
    })
  return panel
end

return status_panel

