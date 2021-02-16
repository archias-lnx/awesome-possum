local wibox = require('wibox')
local popup = require('module.popup')

local dpi = require('beautiful').xresources.apply_dpi

-- local watch = awful.widget.watch

local notif_popup = {}
notif_popup.build_dashboard = function(args)

  local notification_center = require('widget.notif-center')

  local n_height = dpi(650)
  local n_width = dpi(420)
  local fixed_size_container = wibox.widget {
    notification_center,
    left = dpi(2),
    right = dpi(2),
    forced_height = n_height,
    forced_width = n_width,
    widget = wibox.container.margin
  }

  local popupargs = {
    name = 'notif_osd',
    height = n_height,
    width = n_width,
    content = fixed_size_container
  }
  popup(popupargs)

  return notification_center
end

return notif_popup