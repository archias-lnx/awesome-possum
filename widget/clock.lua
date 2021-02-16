local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')

local dpi = require('beautiful').xresources.apply_dpi
local callbacks = require('widget.callbacks')

local icons = require('theme.icons')

--- This is the returned type - a table with a build function to create the widget.
--- it may contain more widget
local clock_widget = {}
clock_widget.build = function(args)
  local widget_layout = wibox.layout.fixed[args.orientation]

  local margins = 0
  if args.callback ~= callbacks.background then
    margins = args.margins or beautiful.margin_size
  end

  local imagebox = wibox.widget {
    {
      id = 'icon',
      image = icons.widget.clock,
      widget = wibox.widget.imagebox,
      resize = true
    },
    layout = widget_layout()
  }
  local textbox = wibox.widget.textclock(
    '<span font="' .. beautiful.font_bold .. ' 11">%H:%M</span>', 1)

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

  -- Tooltip
  local clock_tooltip = awful.tooltip {
    objects = {widget},
    mode = 'outside',
    delay_show = 1,
    preferred_positions = {'right', 'left', 'top', 'bottom'},
    preferred_alignments = {'middle'},
    margin_leftright = dpi(8),
    margin_topbottom = dpi(8),
    timer_function = function()
      local ordinal = nil

      local day = os.date('%d')
      local month = os.date('%B')

      local first_digit = string.sub(day, 0, 1)
      local last_digit = string.sub(day, -1)

      if first_digit == '0' then
        day = last_digit
      end

      if last_digit == '1' and day ~= '11' then
        ordinal = 'st'
      elseif last_digit == '2' and day ~= '12' then
        ordinal = 'nd'
      elseif last_digit == '3' and day ~= '13' then
        ordinal = 'rd'
      else
        ordinal = 'th'
      end

      local date_str = 'Today is the ' .. '<b>' .. day .. ordinal .. ' of ' ..
                         month .. '</b>.\n' .. 'And it\'s ' .. os.date('%A')
      return date_str
    end
  }

  widget:connect_signal(
    'button::press', function(self, lx, ly, button)
      -- Hide the tooltip when you press the clock widget
      if clock_tooltip.visible and button == 1 then
        clock_tooltip.visible = false
        -- toggle right dashboard where the calendar is now
      end
      args.screen:emit_signal('sidebar::show_mode', 'today')
      awesome.emit_signal('widget::calendar_osd:show', true)
    end)

  return widget
end

return clock_widget
