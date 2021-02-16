local status_panel = require('layout.bottom-panel')
local additional_panel = require('layout.top-panel')
local callbacks = require('widget.callbacks')

screen.connect_signal(
  'request::desktop_decoration', function(s)
    s.status_panel = status_panel(s)
    s.status_panel.visible = true
    -- s.additional_panel = additional_panel(s)
    -- s.additional_panel.visible = true
    local args = {}
    args.orientation = "horizontal"
    args.callback = callbacks.zoom
    require('widget.brightness').build_dashboard(args)
    require('widget.volume').build_dashboard(args)
    require('widget.calendar-popup').build_dashboard(args)
    require('widget.notif-center.notif-popup').build_dashboard(args)
  end)