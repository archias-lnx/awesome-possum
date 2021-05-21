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
local exit_widget = {}

exit_widget.watch_active = false

exit_widget.content = {greeter = 'empty', host = 'empty'}
exit_widget.start_watch = function()
  exit_widget.watch_active = true
  -- Update all the content at initialization
  awful.spawn.easy_async_with_shell(
    [[
		sh -c '
    fullname="$(getent passwd `whoami` | cut -d ':' -f 5 | cut -d ',' -f 1 | tr -d "\n")"

		if [ -z "$fullname" ];
		then
			printf "$(whoami)@$(cat /proc/sys/kernel/hostname)"
		else
			printf "$fullname"
		fi
		'
		]], function(stdout)
      stdout = stdout:gsub('%\n', '')
      local first_name = stdout:match('(.*)@') or stdout:match('(.-)%s')
      exit_widget.content.greeter = 'Choose wisely, ' ..
                                      first_name:sub(1, 1):upper() ..
                                      first_name:sub(2) .. '!'
      exit_widget.content.host = stdout
      awesome.emit_signal('module::exit_screen:update')
    end)
end

-- commands
exit_widget.suspend_command = function()
  awesome.emit_signal('module::exit_screen:hide')
  awesome.emit_signal('module::lock_screen:show')
  awful.spawn.with_shell('systemctl suspend')
  -- awful.spawn.with_shell('sudo nas-umount ; umount-modules ; systemctl suspend')
end
exit_widget.lock_command = function()
  awesome.emit_signal('module::exit_screen:hide')
  awesome.emit_signal('module::lock_screen:show')
end
exit_widget.exit_command = function()
  awful.spawn.with_shell('killall -q awesome')
end
exit_widget.poweroff_command = function() awful.spawn.with_shell('sudo poweroff') end
-- exit_widget.poweroff_command = function() awful.spawn.with_shell('sudo nas-umount ; umount-modules ; sudo poweroff') end
exit_widget.reboot_command = function() awful.spawn.with_shell('sudo reboot') end
-- exit_widget.reboot_command = function() awful.spawn.with_shell('sudo nas-umount ; umount-modules ; sudo reboot') end

exit_widget.build_button = function(args, icon, function_table, name)

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
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(5),
    {
      shape = gears.shape.rounded_rect,
      forced_width = dpi(90),
      forced_height = dpi(90),
      clickable_icon,
      widget = wibox.container.background
    },
    button_text
  }

  return build_a_button
end

exit_widget.build_leave_widget = function()
  -- content
  local greeter_message = wibox.widget {
    text = exit_widget.content.greeter,
    font = beautiful.font .. ' 48',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
  }
  local profile_name = wibox.widget {
    markup = exit_widget.content.host,
    font = beautiful.font .. ' 12',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
  }

  local profile_imagebox = wibox.widget {
    image = icons.face,
    resize = true,
    forced_height = dpi(120),
    clip_shape = gears.shape.circle,
    widget = wibox.widget.imagebox
  }

  local profile_imagebox_bg = wibox.widget {
    bg = beautiful.groups_bg,
    forced_width = dpi(140),
    forced_height = dpi(140),
    shape = gears.shape.circle,
    widget = wibox.container.background
  }
  local button_args = {}
  local poweroff_button = exit_widget.build_button(
    button_args, icons.power, function() exit_widget.poweroff_command() end,
      'Shutdown')
  local reboot_button = exit_widget.build_button(
    button_args, icons.restart, function() exit_widget.reboot_command() end,
      'Restart')
  local suspend_button = exit_widget.build_button(
    button_args, icons.sleep, function() exit_widget.suspend_command() end,
      'Suspend')
  local exit_button = exit_widget.build_button(
    button_args, icons.logout, function() exit_widget.exit_command() end,
      'Logout')
  local lock_button = exit_widget.build_button(
    button_args, icons.lock, function() exit_widget.lock_command() end, 'Lock')

  local allcontent = wibox.widget {
    layout = wibox.layout.align.vertical,
    {
      nil,
      {
        layout = wibox.layout.fixed.vertical,
        spacing = dpi(5),
        {
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
          layout = wibox.layout.stack
        },
        profile_name
      },
      nil,
      expand = 'none',
      layout = wibox.layout.align.horizontal
    },
    {
      layout = wibox.layout.align.horizontal,
      expand = 'none',
      nil,
      {widget = wibox.container.margin, margins = dpi(15), greeter_message},
      nil
    },

    {
      layout = wibox.layout.align.horizontal,
      expand = 'none',
      nil,
      {
        {
          {
            poweroff_button,
            reboot_button,
            suspend_button,
            exit_button,
            lock_button,
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
    },
    nil
  }
  local keypresstable = {
    l = function() exit_widget.lock_command() end,
    s = function() exit_widget.suspend_command() end,
    p = function() exit_widget.poweroff_command() end,
    r = function() exit_widget.reboot_command() end,
    e = function() exit_widget.exit_command() end
  }
  local args = {
    content = allcontent,
    name = 'exit_screen',
    keypresstable = keypresstable
  }
  build_dashboard(args)

  awesome.connect_signal(
    'module::exit_screen:update', function()
      profile_name:set_text(exit_widget.content.host)
      greeter_message:set_markup(exit_widget.content.greeter)
    end)

  -- do this always for every screen
  if exit_widget.watch_active == false then
    exit_widget.start_watch()
  end
end

exit_widget.build_leave_widget()
