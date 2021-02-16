local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')

local dpi = require('beautiful').xresources.apply_dpi
local clickable_image = require('widget.clickable-image')

local apps = require('configuration.apps')
local icons = require('theme.icons')


local add_button_widget = {}

add_button_widget.build = function(args)
  local widget_button = clickable_image(
    args, icons.widget.plus, function()
      awful.spawn(
        awful.screen.focused().selected_tag.default_app, {
          tag = mouse.screen.selected_tag,
          placement = awful.placement.bottom_right
        })
    end)
  -- local imagebox = wibox.widget {
  --   id = 'icon',
  --   image = icons.widget.plus,
  --   resize = true,
  --   widget = wibox.widget.imagebox
  -- }

  -- local widget_button = wibox.widget {
  --   {imagebox, margins = dpi(10), widget = wibox.container.margin},
  --   widget = clickable_container
  -- }

  awful.tooltip {
    objects = {widget_button},
    mode = 'outside',
    delay_show = 1,
    preferred_positions = {'right', 'left', 'top', 'bottom'},
    preferred_alignments = {'middle'},
    margin_leftright = dpi(8),
    margin_topbottom = dpi(8),
    timer_function = function()
      return 'Launch ' .. awful.screen.focused().selected_tag.default_app
    end
  }

  return widget_button
end

return add_button_widget
