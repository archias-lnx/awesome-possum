local wibox = require('wibox')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi

local notif_header = wibox.widget {
  text = 'Notification Center',
  font = beautiful.font_bold .. ' 14',
  align = 'left',
  valign = 'bottom',
  widget = wibox.widget.textbox
}

return wibox.widget {
  expand = 'none',
  layout = wibox.layout.fixed.vertical,
  spacing = dpi(10),
  {
    expand = 'none',
    layout = wibox.layout.align.horizontal,
    notif_header,
    nil,
    {
      layout = wibox.layout.fixed.horizontal,
      spacing = dpi(5),
      require('widget.notif-center.dont-disturb').widget,
      require('widget.notif-center.clear-all')
    }
  },
  require('widget.notif-center.build-notifbox')
}
