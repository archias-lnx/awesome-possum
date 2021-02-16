local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')

local callbacks = require('widget.callbacks')
local icons = require('theme.icons')
local modkey = require('configuration.keys.mod').modKey
--- This is the returned type - a table with a build function to create the widget.
--- it may contain more widget
local taglist = {}
taglist.show_current_client = false
taglist.filter = awful.widget.taglist.filter.all

taglist.update_function = function(self, _, index, _)
  taglist.update_function_dot_dash(self, nil, index, nil)
  local marginbox = self:get_children_by_id('zoom_margin')[1]
  local tag = self.screen.tags[index]
  for _, c in ipairs(self.screen:get_all_clients()) do
    if c.first_tag == tag and c.icon then
      self.clientwidget.client = c
      marginbox.widget = self.clientwidget
      return
    end
  end
  self.textwidget.text = tostring(index)
  marginbox.widget = self.textwidget
end

taglist.update_function_dot_dash = function(self, _, index, _)
  local tag = self.screen.tags[index]
  local state_icon = self:get_children_by_id('icon_state_role')[1]
  local background = self:get_children_by_id('background_role')[1]
  local image = nil
  if tag.selected then
    io.stderr:write('setting image toggled on')
    image = icons.tag_focused
  elseif tag.urgent then
    image = icons.tag_urgent
  elseif #tag:clients() > 0 then
    image = icons.tag_occupied
  else
    image = icons.tag_empty
  end
  state_icon:set_image(image)
end

taglist.widget_template_builder = function(args)
  local margins = 0
  if args.callback ~= callbacks.background then
    margins = args.margins or beautiful.margin_size
  end
  local icon_ratio = 0.8
  local tag_icon_container = {
    {
      id = 'icon_role',
      image = icons.widget.settings,
      resize = true,
      widget = wibox.widget.imagebox
    },
    id = 'zoom_margin',
    margins = margins,
    widget = wibox.container.margin
  }
  local t = {
    {
      {
        {
          {
            id = 'icon_state_role',
            image = icons.tag_empty,
            resize = true,
            widget = wibox.widget.imagebox
          },
          forced_height = beautiful.panel_height * (1 - icon_ratio),
          halign = 'center',
          valign = 'center',
          widget = wibox.container.place
        },
        {
          tag_icon_container,
          forced_height = beautiful.panel_height * icon_ratio,
          halign = 'center',
          valign = 'center',
          widget = wibox.container.place
        },
        -- layout = wibox.layout.fixed.vertical
        layout = wibox.layout.stack
      },
      -- widget for background depending on tag state
      id = 'background_role',
      widget = wibox.container.background
    },
    widget = wibox.container.background,
    -- widget for background when hovering
    create_callback = args.callback,
    screen = args.screen
  }

  if taglist.show_current_client then
    t.textwidget = {widget = wibox.widget.textbox, font = beautiful.font_heavy .." 12"}
    t.clientwidget = {widget = awful.widget.clienticon}
    t.update_callback = taglist.update_function
  else
    t.update_callback = taglist.update_function_dot_dash
  end
  return t
end

taglist.buttons = awful.util.table.join(
  awful.button({}, 1, function(t) t:view_only() end), awful.button(
    {modkey}, 1, function(t)
      if _G.client.focus then
        _G.client.focus:move_to_tag(t)
        t:view_only()
      end
    end), awful.button({}, 3, awful.tag.viewtoggle), awful.button(
    {modkey}, 3, function(t)
      if _G.client.focus then
        _G.client.focus:toggle_tag(t)
      end
    end), awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end))

taglist.build = function(args)
  return awful.widget.taglist {
    screen = args.screen,
    filter = taglist.filter,
    layout = wibox.layout.fixed[args.orientation],
    widget_template = taglist.widget_template_builder(args),
    buttons = taglist.buttons
  }
end

return taglist
