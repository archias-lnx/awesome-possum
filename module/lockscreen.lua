local awful = require('awful')
local gears = require('gears')
local wibox = require('wibox')
local beautiful = require('beautiful')
local dpi = beautiful.xresources.apply_dpi

local icons = require('theme.icons')
local apps = require('configuration.apps')
local clickable_image = require('widget.clickable-image')
local callbacks = require('widget.callbacks')
local build_dashboard = require('module.dashboard')
local lock_widget = {}

-- TODO:
-- Disable Restart awesome when lock
-- mute mic and sound during locked unmute otherwise
-- Red ring if wrong PW

local characters_entered = 0

lock_widget.locked = false

-- Lock animation
lock_widget.build_animation_arc = function(icon)
  local lock_animation_widget_rotate = wibox.container.rotate()

  local arc = function()
    return function(cr, width, height)
      gears.shape.arc(cr, width, height, dpi(5), 0, math.pi / 2, true, true)
    end
  end

  local lock_animation_arc = wibox.widget {
    shape = arc(),
    bg = '#00000000',
    forced_width = dpi(160),
    forced_height = dpi(160),
    widget = wibox.container.background
  }
  local profile_imagebox = wibox.widget {
    image = icon,
    resize = true,
    forced_height = dpi(140),
    clip_shape = gears.shape.circle,
    widget = wibox.widget.imagebox
  }
  local profile_imagebox_bg = wibox.widget {
    bg = beautiful.groups_bg,
    forced_width = dpi(160),
    forced_height = dpi(160),
    shape = gears.shape.circle,
    widget = wibox.container.background
  }

  local lock_animation_widget = {
    profile_imagebox_bg,
    {
      layout = wibox.layout.align.vertical,
      expand = 'none',
      nil,
      {
        layout = wibox.layout.align.horizontal,
        expand = 'none',
        nil,
        profile_imagebox,
        nil
      },
      nil
    },
    {lock_animation_arc, widget = lock_animation_widget_rotate},
    layout = wibox.layout.stack

  }
  local animation_colors = {
    '#F1FF5288', '#985EFF88', '#6498EF88', '#24D1E788', '#EE4F8488', '#53E2AE88'
  }
  local animation_directions = {'north', 'west', 'south', 'east'}

  -- Function that "animates" every key press
  awesome.connect_signal(
    'module::lock_screen:key_animation', function(char_inserted)
      local color
      local direction = animation_directions[(characters_entered % 4) + 1]
      if char_inserted then
        color = animation_colors[(characters_entered % 6) + 1]
      else
        if characters_entered == 0 then
          lock_widget.reset()
        else
          color = '#ffffff55'
        end
      end

      lock_animation_arc.bg = color
      lock_animation_widget_rotate.direction = direction
    end)

  awesome.connect_signal(
    'module::lock_screen:key_animation_reset', function()
      lock_animation_widget_rotate.direction = 'north'
      lock_animation_arc.bg = '#00000000'
    end)

  return lock_animation_widget
end

lock_widget.build_button = function(args, icon, function_table, name)
  local clickable_icon, image_to_change =
    clickable_image(args, icon, function_table)
  local button_text = wibox.widget {
    text = name,
    font = beautiful.font .. ' 10',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
  }
  local build_a_button = wibox.widget {
    {
      layout = wibox.layout.align.horizontal,
      expand = 'none',
      nil,
      {
        shape = gears.shape.rounded_rect,
        forced_width = dpi(50),
        forced_height = dpi(50),
        clickable_icon,
        widget = wibox.container.background
      },
      nil
    },
    button_text,
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(5)
  }

  return build_a_button
end

-- FOR AUTHENTICATION
-- A dummy textbox needed to get user input.
-- It will not be visible anywhere.
lock_widget.reset = function()
  characters_entered = 0;
  awesome.emit_signal('module::lock_screen:key_animation_reset')
end
lock_widget.fail = function()
  characters_entered = 0;
  awesome.emit_signal('module::lock_screen:key_animation_reset')
end

-- Authenticate function chooser
-- Check module if valid
local module_check = function(name)
  if package.loaded[name] then
    return true
  else
    for _, searcher in ipairs(package.searchers or package.loaders) do
      local loader = searcher(name)
      if type(loader) == 'function' then
        package.preload[name] = loader
        return true
      end
    end
    return false
  end
end

lock_widget.authenticate = function(password)
  if module_check('liblua_pam') then
    local pam = require('liblua_pam')
    return pam:auth_current_user(password)
  else
    return password == '1234'
  end

end

-- Get input from user
local some_textbox = wibox.widget.textbox()
lock_widget.grab_password = function()
  awful.prompt.run {
    hooks = {
      -- Custom escape behaviour: Do not cancel input with Escape
      -- Instead, this will just clear any input received so far.
      {
        {}, 'Escape', function(_)
          lock_widget.reset()
          lock_widget.grab_password()
        end
      }, -- Fix for Control+Delete crashing the keygrabber
      {
        {'Control'}, 'Delete', function()
          lock_widget.reset()
          lock_widget.grab_password()
        end
      }, {
        {'Mod4', 'Control'}, 'r', function()
          lock_widget.reset()
          lock_widget.grab_password()
        end
      }
    },
    -- this at least prohibts reseting for a long amount of time ?!?! -- TODO get to the source why reset sometimes works
    keybindings = awful.key {
      modifiers = {'Mod4', 'Control'},
      key = 'r',
      on_press = function(self)
        lock_widget.reset()
        lock_widget.grab_password()
      end
    },
    keypressed_callback = function(mod, key, cmd)
      -- Only count single character keys (thus preventing
      -- "Shift", "Escape", etc from triggering the animation)
      awesome.emit_signal('dashboard_lockscreen::timer:rerun')
      if #key == 1 then
        characters_entered = characters_entered + 1
        awesome.emit_signal('module::lock_screen:key_animation', true)

      elseif key == 'BackSpace' then
        if characters_entered > 0 then
          characters_entered = characters_entered - 1
        end
        awesome.emit_signal('module::lock_screen:key_animation', false)
      end
    end,
    exe_callback = function(input)
      -- Check input
      if lock_widget.authenticate(input) then
        -- YAY
        lock_widget.reset()
        lock_widget.locked = false
        awesome.emit_signal('module::lock_screen:hide')
      else
        -- NAY
        lock_widget.fail()
        lock_widget.grab_password()
      end
    end,
    textbox = some_textbox
  }
end

-- commands
lock_widget.suspend_command = function()
  awful.spawn.with_shell('sudo nas-umount ; umount-modules ; systemctl suspend')
end
lock_widget.poweroff_command = function() awful.spawn.with_shell('sudo nas-umount ; umount-modules ; sudo poweroff') end

lock_widget.build_leave_widget = function()
  local button_args = {}
  local poweroff_button = lock_widget.build_button(
    button_args, icons.power, function() lock_widget.poweroff_command() end,
      'Shutdown')
  local suspend_button = lock_widget.build_button(
    button_args, icons.sleep, function() lock_widget.suspend_command() end,
      'Suspend')

  local lock_animation_widget = lock_widget.build_animation_arc(icons.face)

  -- Items
  local day_of_the_week = wibox.widget {
    -- Fancy font
    font = beautiful.font_heavy .. '  25',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textclock('%A')
  }

  local month = wibox.widget {
    font = beautiful.font .. '  15',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textclock('%d. %B')
  }

  -- Month + Day of the week stacked on top of each other
  local fancy_date = wibox.widget {
    nil,
    {
      {day_of_the_week, month, nil, layout = wibox.layout.fixed.vertical},
      margins = dpi(5),
      widget = wibox.container.margin
    },
    nil,
    -- Set forced width in order to keep it from getting cut off
    layout = wibox.layout.align.vertical
  }

  local time = {
    {
      font = beautiful.font_heavy .. '  50',
      widget = wibox.widget.textclock('%H')
    },
    {
      font = beautiful.font_heavy .. '  50',
      widget = wibox.widget.textclock(':%M')
    },
    spacing = dpi(2),
    layout = wibox.layout.fixed.horizontal
  }

  local date_time_box = wibox.widget {
    {
      time,
      fancy_date,
      nil,
      spacing = dpi(10),
      layout = wibox.layout.fixed.horizontal
    },
    nil,
    nil,
    layout = wibox.layout.fixed.vertical,
    expand = 'none'
  }

  local suspend_exit_box = wibox.widget {
    layout = wibox.layout.align.horizontal,
    expand = 'none',
    nil,
    {
      {
        {
          poweroff_button,
          suspend_button,
          spacing = dpi(24),
          layout = wibox.layout.fixed.horizontal
        },
        spacing = dpi(30),
        layout = wibox.layout.fixed.vertical
      },
      widget = wibox.container.margin,
      margins = dpi(15)
    },
    nil
  }
  local spacer = wibox.widget {
    layout = wibox.container.margin,
    margins = dpi(150)
  }
  local allcontent = wibox.widget {
    layout = wibox.layout.align.vertical,
    {
      layout = wibox.layout.align.vertical,
      {
        forced_height = dpi(400),
        widget = wibox.container.background,
        bg = '#00000000'
      },
      {
        nil,
        {
          layout = wibox.layout.fixed.vertical,
          spacing = dpi(5),
          {
            {
              layout = wibox.layout.align.vertical,
              expand = 'none',
              nil,
              {
                layout = wibox.layout.align.horizontal,
                expand = 'none',
                -- nil,
                lock_animation_widget
                -- nil
              },
              nil
            },
            layout = wibox.layout.stack
          }
        },
        nil,
        expand = 'none',
        layout = wibox.layout.align.horizontal
      },
      {
        forced_height = dpi(100),
        widget = wibox.container.background,
        bg = '#00000000'
      }
    },
    {
      forced_height = dpi(500),
      widget = wibox.container.background,
      bg = '#00000000'
    },
    {
      {
        {
          nil,
          date_time_box,
          nil,
          expand = 'none',
          layout = wibox.layout.align.vertical
        },
        nil,
        suspend_exit_box,
        layout = wibox.layout.align.horizontal
      },
      margins = dpi(10),
      widget = wibox.container.margin
    }
  }

  local args = {
    content = allcontent,
    screen = screen.primary,
    name = 'lock_screen',
    loopcheck_function = lock_widget.grab_password
  }
  build_dashboard(args)
end

awesome.connect_signal(
  'module::lock_screen:hide', function() lock_widget.locked = true end)
lock_widget.build_leave_widget()

return lock_widget
