local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local naughty = require('naughty')
local beautiful = require('beautiful')

local dpi = require('beautiful').xresources.apply_dpi
local clickable_container = require('widget.clickable-container')
local callbacks = require('widget.callbacks')

local apps = require('configuration.apps')
local configuration = require('configuration')
local icons = require('theme.icons')

local watch = awful.widget.watch

--- This is the returned type - a table with a build function to create the widget.
--- it may contain more widget
local update_interval = configuration.update_interval or 10
local awesome = _G.awesome

local battery_widget = {}
local lastcheck_percentage = 100

battery_widget.watch_active = false
battery_widget.created_widgets = {}
battery_widget.content = {
  battery_detected = true,
  alert = false,
  percentage = 0,
  charging = false,
  battery_name = ''
}

battery_widget.notify_alert = function(state)
  if state:match('alert') then
    naughty.notification(
      {
        icon = icons.widget.battery.alert,
        app_name = 'System notification',
        title = 'Battery is dying!',
        message = 'Only ' .. battery_widget.content.percentage .. '% left!!!',
        urgency = 'critical'
      })
  else
    naughty.notification(
      {
        icon = icons.widget.battery.alert,
        app_name = 'System notification',
        title = 'Charging again!',
        message = 'Battery is charging again!',
        urgency = 'normal'
      })
  end
end

battery_widget.start_watch = function()
  battery_widget.watch_active = true
  -- TODO multiple batteries
  awful.spawn.easy_async_with_shell(
    'ls /sys/class/power_supply/ | grep BAT', function(stdout)
      battery_widget.content.battery_name = stdout:gsub('%\n', '')
    end)

  local check_percentage_cmd = [[
	upower -i $(upower -e | grep BAT) | grep percentage | awk '{print $2}' | tr -d '\n%'
	]]

  local check_status_cmd = [[bash -c "
	upower -i $(upower -e | grep BAT) | grep state | awk '{print $2}' | tr -d '\n'
	"]]

  watch(
    check_status_cmd, update_interval, function(_, stdout)
      local status = stdout:gsub('%\n', '')
      if (status == nil or status == '') then
        battery_widget.content.battery_detected = false
      else
        battery_widget.content.battery_detected = true

        if status:match('discharging') then
          battery_widget.content.charging = false
        elseif status:match('charging') then
          battery_widget.content.charging = true
          if battery_widget.content.percentage < 10 then
            battery_widget.notify_alert('normal')
          end
        end

        -- check percentage
        awful.spawn.easy_async_with_shell(
          check_percentage_cmd, function(stdout)
            local percentage = tonumber(stdout)

            battery_widget.content.percentage = percentage

            if percentage >= 0 and percentage < 10 then
              battery_widget.content.alert = true
              if percentage < lastcheck_percentage then
                battery_widget.notify_alert('alert')
                lastcheck_percentage = percentage
              end
            else
              battery_widget.content.alert = false
            end
          end)

        if status:match('fully') then
          battery_widget.content.percentage = 100
        end
        -- no check status and if it is fully --> set percentage to 100
      end
      awesome.emit_signal('widget:battery:update_icon')
    end)
end

battery_widget.build = function(args)
  local margins = 0
  if args.callback ~= callbacks.background then
    margins = args.margins or beautiful.margin_size
  end
  local widget_layout = function()
    if args.orientation == 'horizontal' then
      return wibox.layout.fixed.horizontal()
    else
      return wibox.layout.fixed.vertical()
    end
  end

  local imagebox = wibox.widget {
    {
      id = 'icon',
      image = icons.widget.battery.std,
      widget = wibox.widget.imagebox,
      resize = true
    },
    layout = wibox.layout.align.horizontal
  }
  local textbox = wibox.widget {
    text = '-',
    font = beautiful.font_bold .. ' 11',
    align = 'left',
    widget = wibox.widget.textbox
  }

  local widget = wibox.widget {
    {
      wibox.widget {layout = widget_layout, spacing = dpi(5), imagebox, textbox},
      id = 'zoom_margin',
      margins = margins,
      widget = wibox.container.margin
    },
    widget = wibox.container.background
  }
  args.callback(widget)

  widget:buttons(
    gears.table.join(
      awful.button(
        {}, 1, nil,
          function() awful.spawn(apps.default.power_manager) end)))

  awful.tooltip(
    {
      objects = {widget},
      mode = 'outside',
      align = 'top',
      preferred_alignments = {'middle'},
      delay_show = 1,
      margin_leftright = dpi(8),
      margin_topbottom = dpi(8),
      timer_function = function()
        local tooltip_string = ''
        local percent_string = tostring(battery_widget.content.percentage)
        if battery_widget.content.battery_detected == false then
          tooltip_string = 'No Battery Detected'
        elseif battery_widget.content.alert then
          tooltip_string = 'Alert!! - only ' .. percent_string .. '% left!!'
        elseif battery_widget.content.charging then
          tooltip_string = 'Charging at ' .. percent_string .. '%'
        else
          tooltip_string = 'Discharging at ' .. percent_string .. '%'
        end
        return tooltip_string
      end,
      preferred_positions = {'right', 'left', 'top', 'bottom'}
    })

  local update_icon = function()
    local percentage = battery_widget.content.percentage
    local icon_name = ''
    imagebox.icon:set_image(icons.widget.battery.alert_red)
    if battery_widget.content.battery_detected == false then
      imagebox.icon:set_image(icons.widget.battery.unknown)
      textbox:set_text('ERR')
    elseif battery_widget.content.alert then
      imagebox.icon:set_image(icons.widget.battery.alert)
      textbox:set_text('!' .. battery_widget.content.percentage .. '%')
    else
      if battery_widget.content.charging then
        icon_name = 'c'
      else
        icon_name = 'n'
      end
      if percentage < 10 then
        icon_name = 'alert'
      elseif percentage >= 10 and percentage < 20 then
        icon_name = icon_name .. '10'
      elseif percentage >= 20 and percentage < 30 then
        icon_name = icon_name .. '20'
      elseif percentage >= 30 and percentage < 50 then
        icon_name = icon_name .. '30'
      elseif percentage >= 50 and percentage < 60 then
        icon_name = icon_name .. '50'
      elseif percentage >= 60 and percentage < 80 then
        icon_name = icon_name .. '60'
      elseif percentage >= 80 and percentage < 90 then
        icon_name = icon_name .. '80'
      elseif percentage >= 90 and percentage < 99 then
        icon_name = icon_name .. '90'
      elseif percentage >= 99 then
        icon_name = icon_name .. '100'
      end
      imagebox.icon:set_image(icons.widget.battery[icon_name])
      textbox:set_text(battery_widget.content.percentage .. '%')
    end
  end

  awesome.connect_signal(
    'widget:battery:update_icon', function() update_icon() end)

  if not battery_widget.watch_active then
    battery_widget.start_watch()
  end

  return widget
end

return battery_widget
