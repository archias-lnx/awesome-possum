local awful = require('awful')
local naughty = require('naughty')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')

local dpi = beautiful.xresources.apply_dpi
local clickable_container = require('widget.clickable-container')
local notification_icons = require('theme.icons').widget.notification

local M = {}
-- Do not disturb status
M.dont_disturb = false
local dont_disturb_file = os.getenv("HOME") .. "/.cache/awesome-disturb-status.txt"

-- Delete button imagebox
local dont_disturb_imagebox = wibox.widget {
  {
    id = 'icon',
    image = notification_icons.dont_disturb_mode,
    resize = true,
    forced_height = dpi(20),
    forced_width = dpi(20),
    widget = wibox.widget.imagebox
  },
  layout = wibox.layout.fixed.horizontal
}

-- Update imagebox
local function update_icon()

  local dd_icon = dont_disturb_imagebox.icon

  if M.dont_disturb then
    dd_icon:set_image(notification_icons.dont_disturb_mode)
  else
    dd_icon:set_image(notification_icons.notify_mode)
  end
end

local check_disturb_status = function()

  local cmd = 'cat ' .. dont_disturb_file

  awful.spawn.easy_async_with_shell(
    cmd, function(stdout)

      local status = stdout

      if status:match('true') then
        M.dont_disturb = true
      elseif status:match('false') then
        M.dont_disturb = false
      else
        M.dont_disturb = false
        awful.spawn.easy_async_with_shell(
          'echo \'false\' > ' .. dont_disturb_file,
            function(stdout) end)
      end

      update_icon()
    end)
end

-- Check status on startup
check_disturb_status()

-- Maintain Status even after awesome.restart() by writing on the widget_dir/ .. disturb_status
local toggle_disturb = function()
  if (M.dont_disturb == true) then

    M.dont_disturb = false

  else
    M.dont_disturb = true
  end

  awful.spawn.easy_async_with_shell(

      'echo ' .. tostring(M.dont_disturb) .. ' > ' .. dont_disturb_file, function(stdout) end)
  update_icon()
end

local dont_disturb_button = wibox.widget {
  {dont_disturb_imagebox, margins = dpi(7), widget = wibox.container.margin},
  widget = clickable_container
}

dont_disturb_button:buttons(
  gears.table.join(awful.button({}, 1, nil, function() toggle_disturb() end)))

-- decorate button
M.widget = wibox.widget {
  nil,
  {
    dont_disturb_button,
    bg = beautiful.groups_bg,
    shape = gears.shape.circle,
    widget = wibox.container.background
  },
  nil,
  expand = 'none',
  layout = wibox.layout.align.vertical
}

-- Create a notification sound
naughty.connect_signal(
  'request::display', function(n)
    -- if not dont_disturb then
    --   awful.spawn.easy_async('canberra-gtk-play -i message', function() end)
    -- end
  end)

return M
