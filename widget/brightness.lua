local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local popup = require('module.popup')

local dpi = require('beautiful').xresources.apply_dpi
local clickable_image = require('widget.clickable-image')
local icons = require('theme.icons')

-- local watch = awful.widget.watch

local brightness_widget = {}

brightness_widget.watch_active = nil
brightness_widget.created_widgets = {}

brightness_widget.value = 0

brightness_widget.start_watch = function()
  brightness_widget.watch_active = true

  -- no watch but central updating of parameters value and mute
  awesome.connect_signal(
    'widget::brightness:set', function(value)
      if value > 100 then
        value = 100
      elseif value < 0 then
        value = 0
      end
      brightness_widget.value = value
      awful.spawn('xbacklight -set ' .. brightness_widget.value, false)
      awesome.emit_signal('widget::brightness:update_visuals')
    end)

  awesome.connect_signal(
    'widget::brightness:change', function(value)
      value = brightness_widget.value + value
      if value > 100 then
        value = 100
      elseif value < 0 then
        value = 0
      end
      brightness_widget.value = value
      awful.spawn('xbacklight -set ' .. brightness_widget.value, false)
      awesome.emit_signal('widget::brightness:update_visuals')
      awesome.emit_signal('widget::brightness_osd:show', true)
    end)

  -- for initialization
  awful.spawn.easy_async_with_shell(
    'xbacklight -get ', function(stdout)
      brightness_widget.value = tonumber(stdout) or 0
      awesome.emit_signal('widget::brightness:update_visuals')
    end)
end

brightness_widget.build_dashboard = function(args)

  -- TODO set those colors from theme.lua
  local slider = wibox.widget {
    nil,
    {
      id = 'brightness_slider',
      bar_shape = gears.shape.rounded_rect,
      bar_height = dpi(2),
      bar_color = '#ffffff20',
      bar_active_color = '#f2f2f2EE',
      handle_color = '#ffffff',
      handle_shape = gears.shape.circle,
      handle_width = dpi(15),
      handle_border_color = '#00000012',
      handle_border_width = dpi(1),
      maximum = 100,
      widget = wibox.widget.slider
    },
    nil,
    expand = 'none',
    layout = wibox.layout.align.vertical
  }

  local buttons = gears.table.join(
    awful.button(
      {}, 1, nil,
        function() awesome.emit_signal('widget::brightness:set', 100) end))

  local widget_button, widget_icon = clickable_image(
    args, icons.widget.brightness, buttons)

  local brightness_dashboard = wibox.widget {
    {

      {
        widget_button,
        top = dpi(3),
        bottom = dpi(3),
        right = dpi(5),
        widget = wibox.container.margin
      },
      slider,
      spacing = dpi(14),
      layout = wibox.layout.fixed.horizontal

    },
    left = dpi(14),
    right = dpi(24),
    forced_height = dpi(48),
    widget = wibox.container.margin
  }

  slider.brightness_slider:connect_signal(
    'property::value', function()
      local brightness_value = slider.brightness_slider:get_value()
      awesome.emit_signal('widget::brightness:set', brightness_value)
    end)

  awesome.connect_signal(
    'widget::brightness:update_visuals',
      function()
        slider.brightness_slider:set_value(brightness_widget.value)
      end)

  if not brightness_widget.watch_active then
    brightness_widget.start_watch()
  end

  local popupargs = {
    name = 'brightness_osd',
    title = 'Brightness',
    content = brightness_dashboard,
    nobackdrop = true
  }
  popup(popupargs)

  return brightness_dashboard
end

return brightness_widget
