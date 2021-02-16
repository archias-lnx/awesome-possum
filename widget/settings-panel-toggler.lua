local awful = require('awful')

local clickable_image = require('widget.clickable-image')
local icons = require('theme.icons')

--- This is the returned type - a table with a build function to create the widget.
--- it may contain more widget
local settings_toggler = {}
settings_toggler.build = function(args)
  local widget = clickable_image {
    orientation = args.orientation,
    icon = icons.widget.settings,
    buttons = function()
      args.screen:emit_signal('sidebar::show_mode', 'settings')
    end,
    tooltip = 'Open Settings Panel'
  }
  return widget
end

return settings_toggler
