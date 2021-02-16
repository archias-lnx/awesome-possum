local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')

local dpi = require('beautiful').xresources.apply_dpi
local callbacks = require('widget.callbacks')

local layout_widget = {}
layout_widget.build = function(args)
  local margins = 0
  if args.callback ~= callbacks.background then
    margins = args.margins or beautiful.margin_size
  end
  local s = args.screen
  local layoutbox = wibox.widget {
    {
      awful.widget.layoutbox(s),
      id = 'zoom_margin',
      margins = margins,
      widget = wibox.container.margin
    },
    widget = wibox.container.background
  }
  args.callback(layoutbox)

  layoutbox:buttons(
    awful.util.table.join(
      awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(1) end),
        awful.button({}, 5, function() awful.layout.inc(-1) end)))

  awful.tooltip {
    objects = {layoutbox},
    mode = 'outside',
    delay_show = 1,
    preferred_positions = {'right', 'left', 'top', 'bottom'},
    preferred_alignments = {'middle'},
    margin_leftright = dpi(8),
    margin_topbottom = dpi(8),
    timer_function = function() return 'Change Layout' end
  }

  return layoutbox
end

return layout_widget
