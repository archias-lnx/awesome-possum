local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local beautiful = require('beautiful')

local callbacks = require('widget.callbacks')
local tooltip = require('widget.tooltip')

local function createClickableImage(args, icon, buttons, tip)
  icon = icon or args.icon
  buttons = buttons or args.buttons
  tip = tip or args.tooltip
  local orientation = args.orientation or 'horizontal'
  local margins = 0
  if args.callback ~= callbacks.background then
    margins = args.margins or beautiful.margin_size
  end

  local iconwidget = wibox.widget {
    {id = 'icon', image = icon, widget = wibox.widget.imagebox, resize = true},
    layout = wibox.layout.align[orientation]
  }

  local widget = wibox.widget {
    {
      iconwidget,
      id = 'zoom_margin',
      margins = margins,
      widget = wibox.container.margin
    },
    widget = wibox.container.background
  }

  local callback = args.callback or callbacks.default
  callback(widget)

  if buttons then
    if type(buttons) == 'table' then
      widget:buttons(buttons)
    else
      widget:buttons(gears.table.join(awful.button({}, 1, nil, buttons)))
    end
  end

  if tip then
    tooltip(widget, tip)
  end

  return widget, iconwidget
end

return createClickableImage
