local clickable_image = require('widget.clickable-image')
local icons = require('theme.icons')

--- This is the returned type - a table with a build function to create the widget.
--- it may contain more widget

local endsession_widget = {}

endsession_widget.build = function(args)
  local widget = clickable_image(
    args, icons.widget.endsession,
      function() awesome.emit_signal('module::exit_screen:show') end,
      'Open Exit Menu')

  return widget
end

return endsession_widget
