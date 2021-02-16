local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi
local gears = require('gears')
local icons = require('theme.icons')
local clickable_image = require('widget.clickable-image')
local beautiful = require('beautiful')

local toggle_systray = {}
toggle_systray.signal = 'widget::systray:toggle'

toggle_systray.build = function(args)
  if args.screen ~= screen.primary then
    return
  end
  -- save the systray on the screen
  args.screen.systray = wibox.widget {
    {
      {
        base_size = dpi(25),
        horizontal = true,
        screen = 'primary',
        widget = wibox.widget.systray
      },
      margins = dpi(5),
      widget = wibox.container.margin
    },
    bg = '#000000FF',
    shape = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, beautiful.panel_widget_radius)
    end,
    widget = wibox.container.background,
    visible = false
  }

  local widget, iconwidget = clickable_image {
    orientation = args.orientation,
    icon = icons.right_arrow,
    buttons = function() awesome.emit_signal(toggle_systray.signal) end,
    tooltip = 'Toggle System Tray'
  }

  awesome.connect_signal(
    toggle_systray.signal, function()
      local systray = args.screen.systray
      systray.visible = not systray.visible
      local icon = systray.visible and icons.left_arrow or icons.right_arrow
      iconwidget.icon:set_image(gears.surface.load_uncached(icon))
    end)
  local returnval = wibox.widget {
    args.screen.systray,
    widget,
    layout = wibox.layout.align[args.orientation]
  }
  return returnval
end
-- {'systray', margins = dpi(5), widget = wibox.container.margin},

return toggle_systray
