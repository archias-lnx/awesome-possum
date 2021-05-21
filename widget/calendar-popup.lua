local beautiful = require('beautiful')
local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local popup = require('module.popup')
local dpi = require('beautiful').xresources.apply_dpi

local calendar_popup = {}
calendar_popup.build_dashboard = function(args)
  local styles = {}

  local function rounded_shape(size)
    return function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, size)
    end
  end

  styles.month = {
    padding = 5,
    bg_color = beautiful.transparent,
    border_width = 0,
    shape = rounded_shape(beautiful.groups_radius)
  }
  styles.normal = {shape = rounded_shape(beautiful.groups_radius)}
  styles.focus = {
    fg_color = beautiful.fg_focus,
    bg_color = beautiful.accent,
    markup = function(t) return '<b>' .. t .. '</b>' end,
    shape = rounded_shape(beautiful.groups_radius)
  }
  styles.header = {
    fg_color = beautiful.fg_focus,
    bg_color = beautiful.background,
    markup = function(t) return '<b>' .. t .. '</b>' end,
    shape = rounded_shape(beautiful.groups_radius)
  }
  styles.weekday = {
    fg_color = beautiful.fg_focus,
    bg_color = beautiful.transparent,
    markup = function(t) return '<b>' .. t .. '</b>' end,
    shape = rounded_shape(beautiful.groups_radius)
  }

  local function decorate_cell(widget, flag, date)
    if flag == 'monthheader' and not styles.monthheader then
      flag = 'header'
    end
    local props = styles[flag] or {}
    if props.markup and widget.get_text and widget.set_markup then
      widget:set_markup(props.markup(widget:get_text()))
    end
    -- Change bg color for weekends
    local d = {
      year = date.year,
      month = (date.month or 1),
      day = (date.day or 1)
    }
    local weekday = tonumber(os.date('%w', os.time(d)))
    local default_bg =
      (weekday == 0 or weekday == 6) and beautiful.background or
        beautiful.transparent
    local ret = wibox.widget {
      {
        widget,
        margins = (props.padding or 2) + (props.border_width or 0),
        widget = wibox.container.margin
      },
      shape = props.shape,
      shape_border_color = props.border_color or '#b9214f',
      shape_border_width = props.border_width or 0,
      fg = props.fg_color or beautiful.fg_focus,
      bg = props.bg_color or default_bg,
      widget = wibox.container.background
    }
    return ret
  end

  local cal = wibox.widget {
    date = os.date('*t'),
    fn_embed = decorate_cell,
    font = beautiful.font .. ' 12',
    widget = wibox.widget.calendar.month
  }

  local inc_month = function(step)
    local da = os.date('*t')
    da.month = cal.date.month + step
    cal:set_date(da)
  end

  local res_month = function(step)
    local da = os.date('*t')
    cal:set_date(da)
  end

  cal:buttons(
    gears.table.join(
      awful.button({}, 1, nil, function() inc_month(1) end),
      awful.button({}, 2, nil, function() res_month() end),
        awful.button({}, 3, nil, function() inc_month(-1) end)))

  local n_height = dpi(370)
  local n_width = dpi(370)



  -- TODO : add the time above the calendar
  local fixed_size_container = wibox.widget {
    cal,
    left = dpi(2),
    right = dpi(2),
    forced_height = n_height,
    forced_width = n_width,
    widget = wibox.container.margin
  }

  local popupargs = {
    name = 'calendar_osd',
    height = n_height,
    width = n_width,
    content = fixed_size_container
  }
  popup(popupargs)

  return cal
end

return calendar_popup
