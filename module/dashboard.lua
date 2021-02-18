local awful = require('awful') local gears = require('gears')
local wibox = require('wibox')
local beautiful = require('beautiful')
local configuration = require('configuration')

local build_screen_dashboard = function(args)
  local lscreen = args.screen
  local name = args.name
  local blur_type = args.noblur and 'dock' or 'splash'

  -- screen itself
  local dashboard = wibox {
    screen = lscreen,
    type = blur_type,
    visible = false,
    id = args.name,
    ontop = true,
    bg = beautiful.background,
    fg = beautiful.fg_normal,
    height = lscreen.geometry.height,
    width = lscreen.geometry.width,
    x = lscreen.geometry.x,
    y = lscreen.geometry.y
  }

  if args.loopcheck_function == nil then
    dashboard:buttons(
      gears.table.join(
        awful.button(
          {}, 2,
            function()
              awesome.emit_signal('module::' .. name .. ':hide')
            end), awful.button(
          {}, 3,
            function()
              awesome.emit_signal('module::' .. name .. ':hide')
            end)))
  end

  dashboard:setup{
    layout = wibox.layout.align.vertical,
    expand = 'none',
    nil,
    args.content,
    nil
  }

  local dashboard_grabber = awful.keygrabber {
    auto_start = true,
    stop_event = 'release',
    keypressed_callback = function(self, mod, key, command)
      if key == 'Escape' or key == 'q' or key == 'x' then
        awesome.emit_signal('module::' .. name .. ':hide')
      else
        -- Here error handling if key is not in table
        for entry in pairs(args.keypresstable) do
          if string.match(key, entry) then
            args.keypresstable[key]()
          end
        end

      end
    end
  }

  -- screen of timer
  local hide_timer = gears.timer {
    timeout = 10,
    autostart = true,
    callback = function()
      if dashboard.visible and args.loopcheck_function ~= nil then
        awful.spawn.with_shell('xset dpms force off')
        awesome.emit_signal('dashboard_lockscreen::timer:rerun')
      end
    end
  }

  awesome.connect_signal(
    'dashboard_lockscreen::timer:rerun', function()
      if hide_timer.started then
        hide_timer:again()
      else
        hide_timer:start()
      end
    end)

  -- Signals
  awesome.connect_signal(
    'module::' .. name .. ':show', function()
      -- show it on all screens
      dashboard.visible = not dashboard.visible
      if lscreen == screen.primary then
        if args.loopcheck_function ~= nil then
          hide_timer:start()
          awful.spawn.with_shell('playerctl pause')
          args.loopcheck_function()
          -- assume: must be a lockscreen
        else
          hide_timer:stop()
          dashboard_grabber:start()
        end
      end
    end)

  awesome.connect_signal(
    'module::' .. name .. ':hide', function()
      dashboard.visible = false
      if lscreen == screen.primary then
        if args.loopcheck_function ~= nil then
          hide_timer:stop()
          awful.spawn.with_shell('playerctl play')
          -- assume: must be a lockscreen
        else
          hide_timer:stop()
          dashboard_grabber:stop()
        end
      end
    end)
end

local function build_dashboard(args)
  for s in screen do
    args.screen = s
    build_screen_dashboard(args)
  end
end

return build_dashboard
