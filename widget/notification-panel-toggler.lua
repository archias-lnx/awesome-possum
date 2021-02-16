local clickable_image = require('widget.clickable-image')
local icons = require('theme.icons')

local notification_toggler_widget = {}
notification_toggler_widget.build = function(args)
  local widget = clickable_image(
    args, icons.widget.notification_button, function()
      args.screen:emit_signal('sidebar::show_mode', 'notif')
      awesome.emit_signal('widget::notif_osd:show', true)
    end, 'Open Notifications Panel')
  return widget
end

return notification_toggler_widget
