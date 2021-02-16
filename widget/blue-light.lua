local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')

local dpi = require('beautiful').xresources.apply_dpi
local clickable_image = require('widget.clickable-image')
local icons = require('theme.icons')

-- local watch = awful.widget.watch

local blue_light_widget = {}

blue_light_widget.watch_active = nil
blue_light_widget.created_widgets = {}

blue_light_widget.enabled = true

blue_light_widget.start_watch = function()
  blue_light_widget.watch_active = true

  local toggle_action = function()
    awful.spawn.easy_async_with_shell(
      [[
		pgrep redshift > /dev/null && (redshift -x && pkill redshift && echo 'OFF') || 
		(echo 'ON' && redshift -l 0:0 -t 4500:4500 -r &>/dev/null &)
    ]], function(stdout)
        if string.match(stdout, 'ON') then
          blue_light_widget.enabled = true
        else
          blue_light_widget.enabled = false
        end
      awesome.emit_signal('widget::blue_light:update_visuals')
      end)

  end

  awesome.connect_signal(
    'widget::blue_light:toggle', function()
      toggle_action()
    end)

  -- for initialization: kill it 
  awful.spawn.easy_async_with_shell(
    [[
		redshift -x
		kill -9 $(pgrep redshift)
		]], function()
      blue_light_widget.enabled = false
      awesome.emit_signal('widget::blue_light:update_visuals')
    end)
end

blue_light_widget.build_toggler = function(args)
  local dashboard_text = wibox.widget {
    text = 'Blue Light Filter',
    font = 'SF Pro Text Regular 11',
    align = 'left',
    widget = wibox.widget.textbox
  }
  local dashboard_toggle_button, dashboard_toggle_icon =
    clickable_image(
      args, icons.toggled_off,
        function() awesome.emit_signal('widget::blue_light:toggle') end)

  -- TODO : build it also as a vertical widget
  local blue_light_toggler = wibox.widget {
    {
      nil,
      dashboard_text,
      {
        {
          dashboard_toggle_button,
          top = dpi(2),
          bottom = dpi(2),
          widget = wibox.container.margin
        },
        layout = wibox.layout.fixed.horizontal
      },
      layout = wibox.layout.align.horizontal
    },
    left = dpi(24),
    right = dpi(24),
    forced_height = dpi(48),
    widget = wibox.container.margin
  }

  awesome.connect_signal(
    'widget::blue_light:update_visuals', function()
      if blue_light_widget.enabled then
        dashboard_toggle_icon.icon:set_image(icons.toggled_on)
      else
        dashboard_toggle_icon.icon:set_image(icons.toggled_off)
      end
    end)

  if not blue_light_widget.watch_active then
    blue_light_widget.start_watch()
  end

  return blue_light_toggler
end

return blue_light_widget
