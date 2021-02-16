local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')

local dpi = require('beautiful').xresources.apply_dpi
local clickable_image = require('widget.clickable-image')

local apps = require('configuration.apps')
local icons = require('theme.icons')

--- This is the returned type - a table with a build function to create the widget.
--- it may contain more widget

local app_launcher_block = {}

app_launcher_block.default_apps = {
  {icon = icons.web_browser, command = apps.default.web_browser},
  {icon = icons.file_manager, command = apps.default.gui_file_manager},
  {icon = icons.terminal, command = apps.default.terminal}
}

local build_single_launcher = function(launcher, args)
  local widget = clickable_image {
    orientation = args.orientation,
    icon = launcher.icon,
    margins = dpi(4),
    buttons = function() awful.spawn(launcher.command) end,
    tooltip = 'execute ' .. launcher.command,
  }
  args.margins = nil
  return widget
end

app_launcher_block.build = function(args)
  local t = {
    layout = wibox.layout.align.horizontal,
    widget = wibox.container.margin
  }

  for i, launcher in ipairs(app_launcher_block.default_apps) do
    t[i] = build_single_launcher(launcher, args)
  end

  local launcher_block = wibox.widget(t)
  return launcher_block
end

return app_launcher_block
