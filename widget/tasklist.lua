local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')

local callbacks = require('widget.callbacks')

local tasklist = {}

tasklist.buttons = awful.util.table.join(
  awful.button(
    {}, 1, function(c)
      if c == _G.client.focus then
        c.minimized = true
      else
        -- Without this, the following
        -- :isvisible() makes no sense
        c.minimized = false
        if not c:isvisible() and c.first_tag then
          c.first_tag:view_only()
        end
        -- This will also un-minimize
        -- the client, if needed
        _G.client.focus = c
        c:raise()
      end
    end), awful.button({}, 2, function(c) c:kill() end),
    awful.button({}, 4, function() awful.client.focus.byidx(1) end),
    awful.button({}, 5, function() awful.client.focus.byidx(-1) end))

tasklist.build = function(args)
  local margins = 0
  if args.callback ~= callbacks.background then
    margins = args.margins or beautiful.margin_size
  end
  return awful.widget.tasklist {
    screen = args.screen,
    filter = awful.widget.tasklist.filter.currenttags,
    widget_template = {
      {
        {
          {
            id = 'clienticon',
            widget = awful.widget.clienticon,
          },
          id = 'zoom_margin',
          margins = margins,
          widget = wibox.container.margin
        },
        id = 'background_role',
        widget = wibox.container.background
      },
      widget = wibox.container.background,
      create_callback = args.callback
    },
    buttons = tasklist.buttons,
    layout = wibox.layout.fixed[args.orientation]()
  }
end

return tasklist
