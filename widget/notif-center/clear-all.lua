local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')

local dpi = require('beautiful').xresources.apply_dpi
local clickable_container = require('widget.clickable-container')
local notification_icons = require('theme.icons').widget.notification

-- Delete button imagebox
local delete_imagebox = wibox.widget {
  {
    image = notification_icons.clear_all,
    resize = true,
    forced_height = dpi(20),
    forced_width = dpi(20),
    widget = wibox.widget.imagebox
  },
  layout = wibox.layout.fixed.horizontal
}

local delete_button = wibox.widget {
  {delete_imagebox, margins = dpi(7), widget = wibox.container.margin},
  widget = clickable_container
}

delete_button:buttons(
  gears.table.join(
    awful.button({}, 1, nil, function() awesome.emit_signal("notifications::clear") end)))

local delete_button_wrapped = wibox.widget {
  nil,
  {
    delete_button,
    bg = beautiful.groups_bg,
    shape = gears.shape.circle,
    widget = wibox.container.background
  },
  nil,
  expand = 'none',
  layout = wibox.layout.align.vertical
}

return delete_button_wrapped
