local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')

local dpi = beautiful.xresources.apply_dpi
local gears = require('gears')
local clickable_container = require('widget.clickable-container')
local icons = require('theme.icons')


local exit_button
local search_button
do
  do -- exit button
    local exit_widget = {
      {
        {
          {image = icons.logout, resize = true, widget = wibox.widget.imagebox},
          top = dpi(12),
          bottom = dpi(12),
          widget = wibox.container.margin
        },
        {
          text = 'End work session',
          font = 'SF Pro Text Regular 12',
          align = 'left',
          valign = 'center',
          widget = wibox.widget.textbox
        },
        spacing = dpi(24),
        layout = wibox.layout.fixed.horizontal
      },
      left = dpi(24),
      right = dpi(24),
      forced_height = dpi(48),
      widget = wibox.container.margin
    }

    exit_button = wibox.widget {
      {exit_widget, widget = clickable_container},
      bg = beautiful.groups_bg,
      shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, beautiful.groups_radius)
      end,
      widget = wibox.container.background
    }

    exit_button:buttons(
      awful.util.table.join(
        awful.button(
          {}, 1, function()
            _G.panel:toggle()
            _G.exit_screen_show()
          end)))

  end
  do
    local search_widget = wibox.widget {
      {
        {
          {image = icons.search, resize = true, widget = wibox.widget.imagebox},
          top = dpi(12),
          bottom = dpi(12),
          widget = wibox.container.margin
        },
        {
          text = 'Document Search',
          font = 'SF Pro Text Regular 12',
          align = 'left',
          valign = 'center',
          widget = wibox.widget.textbox
        },
        spacing = dpi(24),
        layout = wibox.layout.fixed.horizontal
      },
      left = dpi(24),
      right = dpi(24),
      forced_height = dpi(48),
      widget = wibox.container.margin
    }

    search_button = wibox.widget {
      {search_widget, widget = clickable_container},
      bg = beautiful.groups_bg,
      shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, beautiful.groups_radius)
      end,
      widget = wibox.container.background
    }

    search_button:buttons(
      awful.util.table.join(
        awful.button({}, 1, function() _G.panel:run_rofi() end)))
  end
end

local right_panel = function(s)

  -- Set right panel geometry
  local args = {orientation = 'horizontal', screen = s}
  local panel_width = dpi(350)
  local panel_x = s.geometry.x + s.geometry.width - panel_width

  local panel = wibox {
    ontop = true,
    screen = s,
    type = 'panel',
    width = panel_width,
    height = s.geometry.height,
    x = panel_x,
    y = s.geometry.y,
    bg = beautiful.background,
    fg = beautiful.fg_normal
  }

  panel.open = false

  -- backdrop wibox to click on if you want to leave the sidebar
  s.backdrop_area = wibox {
    ontop = true,
    screen = s,
    bg = beautiful.transparent,
    type = 'dock',
    x = s.geometry.x,
    y = s.geometry.y,
    width = s.geometry.width,
    height = s.geometry.height
  }
  s.backdrop_area:buttons(
    awful.util.table.join(
      awful.button({}, 1, function() s:emit_signal('sidebar::hide') end)))

  panel:struts{right = 0}

  local function set_visibility(visible)
    -- order is important here!
    s.backdrop_area.visible = visible
    panel.visible = visible
  end

  io.stderr:write('creating mode container wibox\n')
  local notif_center_widget = require('widget.notif-center')
  local mode_container = wibox.widget {
    layout = wibox.layout.stack,
    {
      id = 'settings_id',
      visible = true,
      {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(7),
        -- require('widget.hardware-monitor-widget').build_dashboard(args),
        require('widget.quick-settings'),
        -- require('widget.network-widget').build_dashboard(args),
        exit_button
      },
      layout = wibox.layout.align.vertical
    },
    {
      id = 'today_id',
      visible = false,
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(7),
        require('widget.user-profile'),
        require('widget.calendar-popup').build_dashboard(args)
      }

    },
    {
      id = 'notif_id',
      visible = false,
      require('widget.notif-center'),
      layout = wibox.layout.fixed.vertical
    }
  }
  io.stderr:write('creating mode container wibox finished\n')

  local function show_mode(mode)
    for _, mode_widget in ipairs(mode_container:get_children()) do
      mode_widget.visible = false
    end
    mode_container:get_children_by_id(mode .. '_id')[1].visible = true
    set_visibility(true)
  end

  s:connect_signal(
    'sidebar::toggle', function() set_visibility(not panel.visible) end)
  s:connect_signal('sidebar::show', function() set_visibility(true) end)
  s:connect_signal('sidebar::hide', function() set_visibility(false) end)
  s:connect_signal('sidebar::show_mode', function(_, mode) show_mode(mode) end)

  local separator = wibox.widget {
    orientation = 'horizontal',
    opacity = 0.0,
    forced_height = 15,
    widget = wibox.widget.separator
  }

  local line_separator = wibox.widget {
    orientation = 'horizontal',
    forced_height = dpi(1),
    span_ratio = 1.0,
    color = beautiful.groups_title_bg,
    widget = wibox.widget.separator
  }

  io.stderr:write('setup panel\n')
  panel:setup{
    {
      expand = 'none',
      layout = wibox.layout.fixed.vertical,
      {
        layout = wibox.layout.align.horizontal,
        expand = 'none',
        nil,
        require('layout.right-panel.sidebar-mode-switcher')(args),
        nil
      },
      separator,
      line_separator,
      separator,
      mode_container
    },
    margins = dpi(16),
    widget = wibox.container.margin
  }
  io.stderr:write('setup panel finished\n')

  return panel
end

return right_panel
