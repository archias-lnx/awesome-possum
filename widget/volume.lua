local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local popup = require('module.popup')

local dpi = require('beautiful').xresources.apply_dpi
local clickable_image = require('widget.clickable-image')
local icons = require('theme.icons')

-- local watch = awful.widget.watch

local volume_widget = {}

volume_widget.watch_active = nil
volume_widget.created_widgets = {}

volume_widget.value = 0
volume_widget.mute = false

volume_widget.start_watch = function()
  volume_widget.watch_active = true
  local update_state = function()
    awful.spawn.easy_async_with_shell(
      'amixer -D pulse sget Master', function(stdout)
        if stdout:match('off') then
          volume_widget.mute = true
        else
          volume_widget.mute = false
        end
        local value = tonumber(string.match(stdout, '(%d?%d?%d)%%'))
        if not value then
          io.stderr:write('reading volume failed!!!!!!\n')
          return
        end
        volume_widget.value = value
        awesome.emit_signal('widget::volume:update_visuals')
      end)
  end

  -- no watch but central updating of parameters value and mute
  awesome.connect_signal(
    'widget::volume:set', function(value)
      if not value then
        io.stderr('value volume not set##############\n')
        return
      end
      if value > 100 then
        value = 100
      elseif value < 0 then
        value = 0
      end
      volume_widget.value = value
      awful.spawn.with_shell(
        'for ((i = 0 ; i < 20 ; i++)); do pactl set-sink-volume $i ' ..
          tostring(volume_widget.value) .. '% ; done', false)
    end)

  awesome.connect_signal(
    'widget::volume:change', function(value)
      value = volume_widget.value + value
      if value > 100 then
        value = 100
      elseif value < 0 then
        value = 0
      end
      volume_widget.value = value
      awful.spawn.with_shell(
        'for ((i = 0 ; i < 20 ; i++)); do pactl set-sink-volume $i ' ..
          tostring(volume_widget.value) .. '% ; done', false)
      awesome.emit_signal('widget::volume:update_visuals')
      awesome.emit_signal('widget::volume_osd:show', true)
    end)

  awesome.connect_signal(
    'widget::volume:toggle_mute', function()
      volume_widget.mute = not volume_widget.mute

      if volume_widget.mute then
        awful.spawn.with_shell(
          'for ((i = 0 ; i < 20 ; i++)); do pacmd set-sink-mute $i 1 ; done',
            false)
      else
        awful.spawn.with_shell(
          'for ((i = 0 ; i < 20 ; i++)); do pacmd set-sink-mute $i 0 ; done',
            false)
      end
      awesome.emit_signal('widget::volume:update_visuals')
      awesome.emit_signal('widget::volume_osd:show', true)
    end)

  -- for initialization
  update_state()

  -- so the slider or the osd updates its info

end

volume_widget.build_dashboard = function(args)

  -- TODO set those colors from theme.lua
  local slider = wibox.widget {
    nil,
    {
      id = 'volume_slider',
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
        function() awesome.emit_signal('widget::volume:toggle_mute') end))

  local widget_button, widget_icon = clickable_image(
    args, icons.widget.volume, buttons)

  local volume_dashboard = wibox.widget {
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

  slider.volume_slider:connect_signal(
    'property::value', function()
      local volume_value = slider.volume_slider:get_value()
      awesome.emit_signal('widget::volume:set', volume_value)
    end)

  awesome.connect_signal(
    'widget::volume:update_visuals', function()
      slider.volume_slider:set_value(volume_widget.value)
      if volume_widget.mute then
        widget_icon.icon:set_image(icons.widget.volume_mute)
      else
        widget_icon.icon:set_image(icons.widget.volume)
      end
    end)

  if not volume_widget.watch_active then
    volume_widget.start_watch()

  end

  local popupargs = {
    name = 'volume_osd',
    title = 'Volume',
    content = volume_dashboard,
    nobackdrop = true
  }
  popup(popupargs)

  return volume_dashboard
end

return volume_widget
