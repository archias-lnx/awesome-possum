local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local configuration = require('configuration')

local dpi = require('beautiful').xresources.apply_dpi

local overlay_signal_list = {}

local function build_popup(args)
  -- check if a popup with the same name already existsfor signal in pairs(overlay_signal_list) do
  for signal in pairs(overlay_signal_list) do
    if string.match(
      overlay_signal_list[signal], 'widget::' .. args.name .. ':show') then
      return -1
    end
  end

  -- args.content -- some graphical elements
  -- maybe better without screen as argument:
  local s = awful.screen.focused()
  local popup_box_width = beautiful.osd_width
  if args.width ~= nil then
    popup_box_width = args.width
  end
  local popup_box_height = beautiful.osd_height
  if args.height ~= nil then
    popup_box_height = args.height
  end
  local osd_margin = 2 * beautiful.notification_margin + beautiful.panel_height
  local other_margin = 0.5 *
                         (awful.screen.focused().geometry.width -
                           popup_box_width)

  local title_box = nil
  if args.title ~= nil then
    title_box = wibox.widget {
      text = args.title,
      font = beautiful.font .. ' 14',
      align = 'center',
      widget = wibox.widget.textbox
    }
  end

  local popup_box = awful.popup {
    widget = {
      -- Removing this block will cause an error...
    },
    ontop = true,
    visible = false,
    type = 'notification',
    screen = s,
    width = popup_box_width,
    height = popup_box_height,
    maximum_width = popup_box_width,
    maximum_height = popup_box_height,
    offset = dpi(5),
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, beautiful.groups_radius)
    end,
    bg = beautiful.popup_bg,
    preferred_anchors = 'middle',
    preferred_positions = {'left', 'right', 'top', 'bottom'}
  }
  popup_box:setup{
    {
      {
        title_box,
        args.content,
        layout = wibox.layout.fixed.vertical,
        expand = 'none',
        spacing = dpi(8)
      },
      top = dpi(15),
      bottom = dpi(15),
      left = dpi(15),
      right = dpi(15),
      widget = wibox.container.margin

    },
    bg = beautiful.notification_bg1,
    shape = function(cr, width, height)
      gears.shape.partially_rounded_rect(
        cr, width, height, true, true, true, true, beautiful.groups_radius)
    end,
    widget = wibox.container.background()
  }

  -- backdrop so one can click out of it
  local popup_backdrop = wibox {
    ontop = true,
    visible = false,
    screen = s,
    type = 'dock',
    input_passthrough = false,
    bg = beautiful.transparent,
    x = s.geometry.x,
    y = s.geometry.y,
    width = s.geometry.width,
    height = s.geometry.height
  }
  popup_backdrop:buttons(
    gears.table.join(
      awful.button(
        {}, 1, nil, function()
          if popup_backdrop.visible then
            awesome.emit_signal('widget::' .. args.name .. ':show', false)
          end
        end), awful.button(
        {}, 2, nil, function()
          if popup_backdrop.visible then
            awesome.emit_signal('widget::' .. args.name .. ':show', false)
          end
        end), awful.button(
        {}, 3, nil, function()
          if popup_backdrop.visible then
            awesome.emit_signal('widget::' .. args.name .. ':show', false)
          end
        end)))

  -- disappear timer
  local hide_timer = gears.timer {
    timeout = configuration.timeout or 5,
    autostart = true,
    callback = function()
      popup_box.visible = false
      popup_backdrop.visible = false
    end
  }
  local timer_rerun = function()
    if hide_timer.started then
      hide_timer:again()
    else
      hide_timer:start()
    end
  end
  -- so hovering keeps the box from disappearing:
  popup_box:connect_signal('mouse::enter', function() hide_timer:stop() end)
  popup_box:connect_signal('mouse::leave', function() timer_rerun() end)

  local placement_osd = function()
    awful.placement.bottom_left(
      popup_box, {
        margins = {left = other_margin, right = 0, top = 0, bottom = osd_margin},
        parent = awful.screen.focused()
      })
    popup_backdrop:set_screen(awful.screen.focused())
  end

  -- show function
  awesome.connect_signal(
    'widget::' .. args.name .. ':show', function(bool)
      if not popup_box.visible and bool then
        osd_margin = 2 * beautiful.notification_margin + beautiful.panel_height
        other_margin = 0.5 *
                         (awful.screen.focused().geometry.width -
                           popup_box_width)
        placement_osd()
      end
      -- Order important here: first backdrop
      if not args.nobackdrop then
        popup_backdrop.visible = bool
      end
      popup_box.visible = bool
      if bool then
        timer_rerun()
        -- do not show all other popup boxes
        for signal in pairs(overlay_signal_list) do
          if not string.match(
            overlay_signal_list[signal], 'widget::' .. args.name .. ':show') then
            awesome.emit_signal(overlay_signal_list[signal], false)
          end
        end
      end
    end)
  -- toggle function
  awesome.connect_signal(
    'widget::' .. args.name .. ':toggle', function()
      local bool = not popup_box.visible
      if not popup_box.visible then
        osd_margin = 2 * beautiful.notification_margin + beautiful.panel_height
        other_margin = 0.5 *
                         (awful.screen.focused().geometry.width -
                           popup_box_width)
        placement_osd()
      end
      -- Order important here: first backdrop
      if not args.nobackdrop then
        popup_backdrop.visible = bool
      end
      popup_box.visible = bool
      if bool then
        timer_rerun()
        -- do not show all other popup boxes
        for signal in pairs(overlay_signal_list) do
          if not string.match(
            overlay_signal_list[signal], 'widget::' .. args.name .. ':show') then
            awesome.emit_signal(overlay_signal_list[signal], false)
          end
        end
      end
    end)

  local max_index = #overlay_signal_list
  overlay_signal_list[max_index + 1] = 'widget::' .. args.name .. ':show'
  io.stderr:write('Popup added: ' .. 'widget::' .. args.name .. ':show\n')
end

return build_popup
