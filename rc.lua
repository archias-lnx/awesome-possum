local addtional_path_prefix = os.getenv('HOME') .. '/Git/awesome-possum/'
local additonal_path = ';' .. addtional_path_prefix .. '?/init.lua;' ..
                         addtional_path_prefix .. '?.lua'
package.path = package.path .. additonal_path
local logfile = io.open('/tmp/myawesome.log', 'a')
logfile:write('\n\n\nLoading Awesome\nPath: ', package.path, '\n\n')
io.stderr = logfile

local awful = require('awful')
local beautiful = require('beautiful')
local root = _G.root
local client = _G.client

awful.util.shell = '/bin/bash'
--  ========================================
-- 			       Theme
--	     	Load the Aesthetics
--  ========================================
beautiful.init(require('theme'))

--  ========================================
-- 			  	  Layouts
--	     	   Load the Panels
--  ========================================

require('layout')
-- _G.mymainmenu =require('module.menu')

--  ========================================
-- 			      Modules
--	        Load all the modules
--  ========================================

require('module.notifications')
require('module.auto-start')
require('module.decorate-client')
require('module.exit-screen')
require('module.lockscreen')
-- require('module.dashboard-screen')
require('module.titlebar')
-- require('module.menu')


-- require('module.battery-notifier')



-- since this is layout --> configured there
-- require('module.volume-osd')
-- require('module.brightness-osd')


-- just to get the popups with nothing else:
-- vol_widget = require('widget.volume')
-- vol_widget.build_dashboard(args)
-- bright_widget = require('widget.brightness')
-- bright_widget.build_dashboard(args)


-- require('module.volume-osd')
-- require('module.brightness-osd')

--  ========================================
-- 				Configuration
--	     	Load your prefrences
--  ========================================

require('configuration.client')
require('configuration.tags')
root.keys(require('configuration.keys.global'))


-- Signal function to execute when a new client appears.
client.connect_signal(
  'manage', function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not _G.awesome.startup then
      awful.client.setslave(c)
    end

    if _G.awesome.startup and not c.size_hints.user_position and
      not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(c)
    end
  end)

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal(
--   'mouse::enter', function(c)
--     c:emit_signal('request::activate', 'mouse_enter', {raise = true})
--   end)

client.connect_signal(
  'focus', function(c) c.border_color = beautiful.border_focus end)

client.connect_signal(
  'unfocus', function(c) c.border_color = beautiful.border_normal end)

awful.spawn.with_shell('~/.config/awesome/autostart.sh')
