local awful = require('awful')
local gears = require('gears')
local beautiful = require('beautiful')
local wibox = require('wibox')
local dpi = beautiful.xresources.apply_dpi

awful.titlebar.enable_tooltip = false
awful.titlebar.fallback_name = 'Client\'s name'

local dpimargin = beautiful.titlebar_button_margin
local dpispacing = beautiful.titlebar_button_spacing

local titlebar_size = beautiful.titlebar_size

local double_click_timer
local function double_click_event_handler(double_click_event)
  if double_click_timer then
    double_click_timer:stop()
    double_click_timer = nil
    double_click_event()
    return
  end

  double_click_timer = gears.timer.start_new(
    0.20, function()
      double_click_timer = nil
      return false
    end)
end

-- Buttons for moving/resizing functionality
local function createInvisibleButtons(c)
  return gears.table.join(
    awful.button(
      {}, 1, function()
        double_click_event_handler(
          function()
            if c.floating then
              c.floating = false
              return
            end
            c.maximized = not c.maximized
            c:raise()
            return
          end)

        c:activate{context = 'titlebar', action = 'mouse_move'}
      end), awful.button({}, 2, function() c:kill() end), awful.button(
      {}, 3,
        function()
          c:activate{context = 'titlebar', action = 'mouse_resize'}
        end))
end

local decorate_titlebar = function(c, bg, size)
  local valid_pos = {left = true, right = true, top = true, bottom = true}

  local titlebar_pos = beautiful.titlebar_pos
  local button_pos = beautiful.titlebar_button_pos

  if not valid_pos[titlebar_pos] then
    titlebar_pos = 'left'
  end
  if not valid_pos[button_pos] then
    button_pos = 'top'
  end

  local layout = (titlebar_pos == 'left' or titlebar_pos == 'right') and
                   'vertical' or 'horizontal'
  local floating_button_first = button_pos == 'right' or button_pos == 'bottom'

  local control_buttons = {margins = dpimargin, widget = wibox.container.margin}
  if floating_button_first then
    control_buttons[1] = {
      awful.titlebar.widget.minimizebutton(c),
      awful.titlebar.widget.maximizedbutton(c),
      awful.titlebar.widget.closebutton(c)
    }
  else
    control_buttons[1] = {
      awful.titlebar.widget.closebutton(c),
      awful.titlebar.widget.maximizedbutton(c),
      awful.titlebar.widget.minimizebutton(c)
    }
  end
  control_buttons[1].spacing = dpispacing
  control_buttons[1].layout = wibox.layout.fixed[layout]

  local buttons = createInvisibleButtons(c)

  local floating_button = {
    awful.titlebar.widget.floatingbutton(c),
    margins = dpimargin,
    widget = wibox.container.margin
  }

  local setupTable = {
    layout = wibox.layout.align[layout],
    floating_button_first and floating_button or control_buttons,
    {buttons = buttons, layout = wibox.layout.flex[layout]},
    floating_button_first and control_buttons or floating_button
  }

  awful.titlebar(
    c, {position = titlebar_pos, bg = bg, size = size or titlebar_size}):setup(
    setupTable)
end

local function create_titlebars(c)
  decorate_titlebar(c, '#00000066', titlebar_size)
end

client.connect_signal(
  'request::titlebars', create_titlebars)

-- TODO how to do this
client.connect_signal(
  'manage', function(c)
    if c.max and beautiful.titlebar_enabled then
      awful.titlebar.show(c, beautiful.titlebar_pos)
    else
      awful.titlebar.hide(c, beautiful.titlebar_pos)
    end

  end)

-- Catch the signal when a client's layout is changed
screen.connect_signal(
  'arrange', function(s)
    for _, c in pairs(s.clients) do
      if beautiful.titlebar_enabled then
        awful.titlebar.show(c, beautiful.titlebar_pos)
      else
        awful.titlebar.hide(c, beautiful.titlebar_pos)
      end
    end
  end)

client.connect_signal(
  'property::maximized', function(c)
    c.shape = gears.shape.rectangle
  end)
