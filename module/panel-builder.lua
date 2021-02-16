local panel_builder = {}
local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local callbacks = require('widget.callbacks')

local dpi = beautiful.xresources.apply_dpi

-- TODO: rework this
local widget_padd_top = beautiful.panel_padding
local widget_padd_bot = beautiful.panel_padding

local swap_orientation = function(orientation)
  return orientation == 'horizontal' and 'vertical' or 'horizontal'
end

local simple_widgets = {}
do -- definition of simple widgets without an extra file
  simple_widgets.systray = {
    build = function(args)
      if args.screen == screen.primary then
        -- save the systray on the screen
        args.screen.systray = wibox.widget {
          {
            base_size = dpi(30),
            horizontal = true,
            screen = 'primary',
            widget = wibox.widget.systray
          },
          visible = false,
          top = dpi(0),
          widget = wibox.container.margin
        }
        return args.screen.systray
      end
    end
  }

  simple_widgets.separator = {
    build = function(args)
      return wibox.widget {
        orientation = swap_orientation(args.orientation),
        forced_height = dpi(1),
        forced_width = dpi(1),
        span_ratio = 0.55,
        widget = wibox.widget.separator
      }
    end
  }
end

local function load_widget(name)
  local loadwidget
  io.stderr:write('try loading widget: ' .. name .. '\n')
  if not pcall(function() loadwidget = require('widget.' .. name) end) then
    io.stderr:write('Loading simple widget: ' .. name .. '\n')
    loadwidget = simple_widgets[name]
  end
  -- error handling
  if not loadwidget then
    io.stderr:write('Panel-builder: widget not found: ' .. name .. '\n')
    return
  end
  if not loadwidget.build then
    io.stderr:write(
        'Panel-builder: widget appears to be missing the build function: ' ..
          name .. '\n')
    return
  end
  return loadwidget
end

local function replaceNamesWithWidgets(args, widgets)
  for key = 1, #widgets do
    local name = widgets[key]
    if type(name) == 'string' then
      local widget = load_widget(name)
      widgets[key] = widget and panel_builder.wrap_widget(widget.build(args)) or
                       nil
    elseif type(name) == 'table' then
      replaceNamesWithWidgets(args, name)
    else
      widgets[key] = nil
    end
  end
  return widgets
end

local function writeTableValuesRecursive(wtable, values)
  -- write entries if not existant
  for key, value in pairs(values) do
    wtable[key] = wtable[key] or value
  end
  -- recursion
  for key = 1, #wtable do
    local value = wtable[key]
    if type(value) == 'table' then
      writeTableValuesRecursive(value, values)
    end
  end
end

function panel_builder.panel_container(args, widget_names)
  local positional_widget_names = false
  for k, v in pairs(widget_names) do
    if string.match(k, '.+_widgets$') then
      v.layout = wibox.layout.fixed[args.orientation]
      v.spacing = dpi(5)

      positional_widget_names = true
    end
  end

  if not positional_widget_names then
    return widget_names
  end

  return {
    {
      layout = wibox.layout.align[args.orientation],
      expand = 'none',
      widget_names.left_widgets,
      widget_names.middle_widgets,
      widget_names.right_widgets
    },
    left = dpi(5),
    right = dpi(5),
    top = dpi(0),
    bottom = dpi(0),
    widget = wibox.container.margin
  }
end

panel_builder.wrap_widget = function(widget)
  return wibox.widget {
    {
      widget,
      border_width = beautiful.panel_widget_border_width,
      border_color = beautiful.panel_widget_border_color,
      -- bg = beautiful.transparent,
      bg = beautiful.panel_widget_bg_color,
      shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, beautiful.panel_widget_radius)
      end,
      widget = wibox.container.background
    },
    top = dpi(widget_padd_top),
    bottom = dpi(widget_padd_bot),
    widget = wibox.container.margin
  }
end

panel_builder.build_single_panel = function(args, widget_names)
  local s = args.screen
  local pos = args.position
  local layout = swap_orientation(args.orientation)
  if args.callback == nil then
    args.callback = callbacks.default
  end

  local panel_width = args.panel_width or beautiful.panel_laptop_width
  local panel_height = args.panel_height or beautiful.panel_height
  local blur_type = args.blur_type or beautiful.panel_blur_type
  local panel_bg = args.panel_bg or beautiful.panel_bg
  local fg_normal = args.fg_normal or beautiful.fg_normal
  local panel_radius = args.panel_radius or beautiful.panel_radius
  widget_padd_top = args.panel_padding or beautiful.panel_padding
  widget_padd_bot = args.panel_padding or beautiful.panel_padding

  local panel_x = s.geometry.x + 0.5 * (s.geometry.width - panel_width)
  local panel_y = s.geometry.y

  if pos == 'bottom' then
    panel_y = panel_y + s.geometry.height - panel_height
  end

  local panel = wibox {
    -- ontop = true,
    screen = s,
    type = blur_type,
    height = panel_height + 1,
    width = panel_width,
    x = panel_x,
    y = panel_y,
    bg = panel_bg,
    fg = fg_normal,
    shape = function(cr, w, h)
      if pos == 'bottom' then
        gears.shape.partially_rounded_rect(
          cr, w, h, true, true, false, false, panel_radius)
      else
        gears.shape.partially_rounded_rect(
          cr, w, h, false, false, true, true, panel_radius)
      end
    end
  }

  if pos == 'bottom' then
    panel:struts{bottom = panel_height}
  else
    panel:struts{top = panel_height}
  end
  panel:connect_signal(
    'mouse::enter', function()
      local w = mouse.current_wibox
      if w then
        w.cursor = 'left_ptr'
      end
    end)

  widget_names = panel_builder.panel_container(args, widget_names)
  local widgets = replaceNamesWithWidgets(args, widget_names)

  panel:setup(widgets)
  return panel
end

panel_builder.build_all_panels = function(args, widget_names)
  local previous_screen = args.screen
  for s in screen do
    args.screen = s
    panel_builder.build_single_panel(args, widget_names)
  end
  args.screen = previous_screen
end

-- Make this fucntion just return the content of the panel to be used elsewhere
panel_builder.build_widget_box = function(args, widget_names)
  local panel_height = beautiful.panel_height
  widget_names = panel_builder.panel_container(args, widget_names)
  local widgets = replaceNamesWithWidgets(args, widget_names)

  local widget_box = wibox {
    widgets,
    widget = wibox.container.margin,
    type = beautiful.panel_blur_type,
    height = panel_height + 1,
    bg = beautiful.panel_bg,
    fg = beautiful.fg_normal,
    shape = function(cr, w, h)
      gears.shape.partially_rounded_rect(
        cr, w, h, true, true, false, false, beautiful.panel_radius)
    end
  }
  return widget_box
end

return panel_builder
