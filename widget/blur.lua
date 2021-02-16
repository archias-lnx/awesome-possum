local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')

local dpi = require('beautiful').xresources.apply_dpi
local clickable_image = require('widget.clickable-image')
local icons = require('theme.icons')

-- local watch = awful.widget.watch

local blur_widget = {}

blur_widget.watch_active = nil
blur_widget.created_widgets = {}

blur_widget.value = 0
blur_widget.enabled = true

blur_widget.start_watch = function()
  blur_widget.watch_active = true

  -- no watch but central updating of parameters value and mute
  awesome.connect_signal(
    'widget::blur:set', function(value)
      if value > 100 then
        value = 100
      elseif value < 0 then
        value = 0
      end
      blur_widget.value = value

      awful.spawn.easy_async_with_shell(
        [[
		picom_dir=~/.config/awesome/configuration/picom.conf
		sed -i 's/.*strength = .*/    strength = ]] .. blur_widget.value / 50 * 10 ..
          [[;/g' "${picom_dir}"
		]], function(stdout, stderr) end)
      awesome.emit_signal('widget::blur:update_visuals')
    end)

  local toggle_blur = function(togglemode)

    local toggle_blur_script = [[
	picom_dir=$HOME/.config/awesome/configuration/picom.conf

	# Check picom if it's not running then start it
	if [ -z $(pgrep picom) ]; then
		picom -b --experimental-backends --dbus --config ~/.config/awesome/configuration/picom.conf
	fi

	case ]] .. togglemode .. [[ in
		'enable')
		sed -i -e 's/method = "none"/method = "dual_kawase"/g' "${picom_dir}"
		;;
		'disable')
		sed -i -e 's/method = "dual_kawase"/method = "none"/g' "${picom_dir}"
		;;
	esac
	]]

    -- Run the script
    awful.spawn.easy_async_with_shell(
      toggle_blur_script, function(stdout, stderr) end)

  end

  awesome.connect_signal(
    'widget::blur:toggle', function()
      if blur_widget.enabled then
        toggle_blur('disable')
      else
        toggle_blur('enable')
      end
      blur_widget.enabled = not blur_widget.enabled
      awesome.emit_signal('widget::blur:update_visuals')

    end)

  -- for initialization
  awful.spawn.easy_async_with_shell(
    [[
    grep -F 'strength =' ~/.config/awesome/configuration/picom.conf | awk 'NR==1 {printf $3}' | tr -d ';'
    ]], function(stdout)
      blur_widget.value = tonumber(stdout) / 20 * 100
      awesome.emit_signal('widget::blur:update_visuals')
    end)
  awful.spawn.easy_async_with_shell(
    [[
		grep -F 'method = "none";' ~/.config/awesome/configuration/picom.conf | tr -d '[\"\;\=\ ]'
		]], function(stdout)
      if stdout:match('methodnone') then
        blur_widget.enabled = false
      else
        blur_widget.enabled = true
      end
    end)
end

blur_widget.build_dashboard = function(args)
  -- TODO set those colors from theme.lua
  local slider = wibox.widget {
    nil,
    {
      id = 'blur_slider',
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
      {}, 1, nil, function() awesome.emit_signal('widget::blur:set', 100) end))

  local widget_button, widget_icon = clickable_image(
    args, icons.widget.effects, buttons)

  local blur_dashboard = wibox.widget {
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

  slider.blur_slider:connect_signal(
    'property::value', function()
      local blur_value = slider.blur_slider:get_value()
      awesome.emit_signal('widget::blur:set', blur_value)
    end)

  awesome.connect_signal(
    'widget::blur:update_visuals',
      function() slider.blur_slider:set_value(blur_widget.value) end)

  if not blur_widget.watch_active then
    blur_widget.start_watch()
  end

  return blur_dashboard
end

blur_widget.build_toggler = function(args)
  local dashboard_text = wibox.widget {
    text = 'Blur Effects',
    font = 'SF Pro Text Regular 11',
    align = 'left',
    widget = wibox.widget.textbox
  }
  local dashboard_toggle_button, dashboard_toggle_icon =
    clickable_image(
      args, icons.toggled_off,
        function() awesome.emit_signal('widget::blur:toggle') end)

  -- TODO : build it also as a vertical widget
  local blur_toggler = wibox.widget {
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
    'widget::blur:update_visuals', function()
      if blur_widget.enabled then
        dashboard_toggle_icon.icon:set_image(icons.toggled_on)
      else
        dashboard_toggle_icon.icon:set_image(icons.toggled_off)
      end
    end)

  if not blur_widget.watch_active then
    blur_widget.start_watch()
  end

  return blur_toggler
end

return blur_widget
