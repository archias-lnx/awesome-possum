local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local callbacks = {}

function callbacks.zoom(widget)
  local margin_widget = widget:get_children()[1]
  local old_cursor, old_wibox
  if not margin_widget.top then
    margin_widget = widget:get_children_by_id('zoom_margin')[1]
  end

  -- assumes the margins are all the same
  local margin_small = margin_widget.top or beautiful.margin_size
  local margin_big = margin_small - beautiful.margin_hover_diff
  local old_cursor, old_wibox

  widget:connect_signal(
    'mouse::enter', function()
      margin_widget.margins = margin_big
      -- Hm, no idea how to get the wibox from this signal's arguments...
      local w = mouse.current_wibox
      if w then
        old_cursor, old_wibox = w.cursor, w
        w.cursor = 'hand1'
      end
    end)

  widget:connect_signal(
    'mouse::leave', function()
      margin_widget.margins = margin_small

      if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
      end
    end)


end

function callbacks.zoom_bg(widget)
  local margin_widget = widget:get_children()[1]
  if not margin_widget.top then
    margin_widget = widget:get_children_by_id('zoom_margin')[1]
  end

  -- assumes the margins are all the same
  local margin_small = margin_widget.top or beautiful.margin_size
  local margin_big = margin_small - beautiful.margin_hover_diff
  local old_cursor, old_wibox

  widget:connect_signal(
    'mouse::enter', function()
      widget.bg = beautiful.groups_bg
      margin_widget.margins = margin_big
      -- Hm, no idea how to get the wibox from this signal's arguments...
      local w = mouse.current_wibox
      if w then
        old_cursor, old_wibox = w.cursor, w
        w.cursor = 'hand1'
      end
    end)

  widget:connect_signal(
    'mouse::leave', function()
      widget.bg = beautiful.transparent
      margin_widget.margins = margin_small

      if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
      end
    end)

  widget:connect_signal(
    'button::press', function() widget.bg = beautiful.groups_title_bg end)

  widget:connect_signal(
    'button::release', function() widget.bg = beautiful.groups_bg end)
end

function callbacks.background(widget)
  local old_cursor, old_wibox

  widget:connect_signal(
    'mouse::enter', function()
      widget.bg = beautiful.groups_bg
      -- Hm, no idea how to get the wibox from this signal's arguments...
      local w = mouse.current_wibox
      if w then
        old_cursor, old_wibox = w.cursor, w
        w.cursor = 'hand1'
      end
    end)

  widget:connect_signal(
    'mouse::leave', function()
      widget.bg = beautiful.transparent

      if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
      end
    end)

  widget:connect_signal(
    'button::press', function() widget.bg = beautiful.groups_title_bg end)

  widget:connect_signal(
    'button::release', function() widget.bg = beautiful.groups_bg end)
end

callbacks.default = callbacks.zoom_bg

return callbacks
