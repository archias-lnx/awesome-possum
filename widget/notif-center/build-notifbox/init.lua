local naughty = require('naughty')
local wibox = require('wibox')
local beautiful = require('beautiful')

local dpi = beautiful.xresources.apply_dpi
local notification_icons = require('theme.icons').widget.notification
local empty_notifbox = require(
  'widget.notif-center.build-notifbox.empty-notifbox')

-- Boolean variable to remove empty message
local remove_notifbox_empty = true

-- Notification boxes container layout
local notifbox_layout = wibox.layout.fixed.vertical()

-- Notification boxes container layout spacing
notifbox_layout.spacing = dpi(5)

-- Reset notifbox_layout
local reset_notifbox_layout = function()
  notifbox_layout:reset(notifbox_layout)
  notifbox_layout:insert(1, empty_notifbox)
  remove_notifbox_empty = true
end

_G.awesome.connect_signal("notifications::clear", reset_notifbox_layout)

-- Add empty notification message on start-up
notifbox_layout:insert(1, empty_notifbox)

-- Connect to naughty
naughty.connect_signal(
  'request::display', function(n)

    -- If notifbox_layout has a child and remove_notifbox_empty
    if #notifbox_layout.children == 1 and remove_notifbox_empty then
      -- Reset layout
      notifbox_layout:reset(notifbox_layout)
      remove_notifbox_empty = false
    end

    -- Set background color based on urgency level
    local notifbox_color = beautiful.groups_bg
    if n.urgency == 'critical' then
      notifbox_color = n.bg .. '66'
    end

    -- Check if there's an icon
    local appicon = n.icon or n.app_icon
    if not appicon then
      appicon = notification_icons.new_notification
    end

    -- Throw data from naughty to notifbox_layout
    -- Generates notifbox
    local notifbox_box = require(
      'widget.notif-center.build-notifbox.notifbox-builder')
    notifbox_layout:insert(
      1,
        notifbox_box(n, appicon, n.title, n.message, n.app_name, notifbox_color))
  end)

return notifbox_layout
