local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local callbacks = require('widget.callbacks')

local dpi = require('beautiful').xresources.apply_dpi

local barColor = beautiful.groups_bg

local quick_header = wibox.widget {

    text = 'Quick Settings',
    font = 'SF Pro Text Regular 12',
    align = 'left',
    valign = 'center',
    widget = wibox.widget.textbox

}

local args = {}
args.orientation = "horizontal"
args.callback = callbacks.zoom

return wibox.widget {
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(7),
    {
        layout = wibox.layout.fixed.vertical,
        {
            {
                quick_header,
                left = dpi(24),
                right = dpi(24),
                widget = wibox.container.margin
            },
            forced_height = dpi(35),
            bg = beautiful.groups_title_bg,
            shape = function(cr, width, height)
                gears.shape.partially_rounded_rect(cr, width, height, true,
                                                   true, false, false,
                                                   beautiful.groups_radius)
            end,
            widget = wibox.container.background

        },

        {
            require('widget.brightness').build_dashboard(args),
            bg = barColor,
            shape = function(cr, width, height)
                gears.shape.partially_rounded_rect(cr, width, height, false,
                                                   false, false, false,
                                                   beautiful.groups_radius)
            end,
            forced_height = dpi(48),
            widget = wibox.container.background

        },
        {
            require('widget.volume').build_dashboard(args),
            bg = barColor,
            shape = function(cr, width, height)
                gears.shape.partially_rounded_rect(cr, width, height, false,
                                                   false, false, false,
                                                   beautiful.groups_radius)
            end,
            forced_height = dpi(48),
            widget = wibox.container.background

        },

        -- {
        -- 	require('widget.wifi.wifi-toggle'),
        -- 	bg = barColor,
        -- 	shape = function(cr, width, height)
        -- 		gears.shape.partially_rounded_rect(cr, width, height, false, false, false, false, beautiful.groups_radius) end,
        -- 	forced_height = dpi(48),
        -- 	widget = wibox.container.background
        -- },

        {
            require('widget.blue-light').build_toggler(args),
            bg = barColor,
            shape = function(cr, width, height)
                gears.shape.partially_rounded_rect(cr, width, height, false,
                                                   false, false, false,
                                                   beautiful.groups_radius)
            end,
            forced_height = dpi(48),
            widget = wibox.container.background
        },
        {
            require('widget.blur').build_toggler(args),
            bg = barColor,
            shape = function(cr, width, height)
                gears.shape.partially_rounded_rect(cr, width, height, false,
                                                   false, false, false,
                                                   beautiful.groups_radius)
            end,
            forced_height = dpi(48),
            widget = wibox.container.background
        },
        {
            require('widget.blur').build_dashboard(args),
            bg = barColor,
            shape = function(cr, width, height)
                gears.shape.partially_rounded_rect(cr, width, height, false,
                                                   false, true, true,
                                                   beautiful.groups_radius)
            end,
            forced_height = dpi(48),
            widget = wibox.container.background
        }
    }
}
