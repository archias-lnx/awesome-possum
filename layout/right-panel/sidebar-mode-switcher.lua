local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local awful = require('awful')

local clickable_container = require('widget.clickable-container')
local dpi = require('beautiful').xresources.apply_dpi



local function mode_switch_button(s, mode, text)
  local inactive_button = beautiful.transparent

  local textbox = wibox.widget {
    text = text,
    font = 'SF Pro Text Bold 10',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
  }

  local button = clickable_container(
    wibox.container.margin(textbox, dpi(0), dpi(0), dpi(7), dpi(7)))

  local wrap = wibox.widget {
    button,
    forced_width = dpi(100),
    bg = inactive_button,
    border_width = dpi(1),
    border_color = beautiful.groups_title_bg,
    shape = function(cr, width, height)
      gears.shape.partially_rounded_rect(
        cr, width, height, false, false, false, false, beautiful.groups_radius)
    end,
    widget = wibox.container.background
  }

  button:buttons(
    gears.table.join(
      awful.button(
        {}, 1, nil, function() s:emit_signal('sidebar::show_mode', mode) end)))

  return wrap
end

local function mode_switcher(args)
  local s = args.screen
  local active_button = beautiful.groups_title_bg
  local inactive_button = beautiful.transparent

  -- small workaround to access the buttons
  local buttonlist = {
    notif = mode_switch_button(s, 'notif', 'Notifications'),
    settings = mode_switch_button(s, 'settings', 'Settings'),
    today = mode_switch_button(s, 'today', 'Today')
  }

  local switcher = wibox.widget {
    expand = 'none',
    layout = wibox.layout.fixed.horizontal,
    buttonlist.notif,
    buttonlist.settings,
    buttonlist.today
  }

  s:connect_signal(
    'sidebar::show_mode', function(_, mode)
      for _, button in ipairs(switcher:get_children()) do
        button.bg = inactive_button
      end
      buttonlist[mode].bg = active_button
    end)

  buttonlist.settings.bg = active_button
  return switcher
end

return mode_switcher