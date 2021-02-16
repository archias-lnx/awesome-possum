local awful = require('awful')
local beautiful = require('beautiful')
local dpi = require('beautiful').xresources.apply_dpi

require('awful.autofocus')

local hotkeys_popup = require('awful.hotkeys_popup').widget

local modkey = require('configuration.keys.mod').modKey
local altkey = require('configuration.keys.mod').altKey
local apps = require('configuration.apps')
local awesome = _G.awesome
local client = _G.client
local drop = require('module.dropdown')

-- Key bindings
local globalKeys = awful.util.table.join(

  -- Awesome
  awful.key(
    {modkey, 'Control'}, 'a', hotkeys_popup.show_help,
      {description = 'show help', group = 'awesome'}),
  awful.key(
    {modkey, 'Control'}, 'r', awesome.restart,
      {description = 'reload awesome', group = 'awesome'}),
  awful.key(
    {modkey, 'Shift', 'Control'}, 'q', awesome.quit,
      {description = 'quit awesome', group = 'awesome'}),
  awful.key(
    {modkey}, 'v', function() awesome.emit_signal('property::fullscreen') end,
      {description = 'Toggle bottom panel', group = 'awesome'}), -- Tag
  awful.key(
    {modkey}, 'Left', awful.tag.viewprev,
      {description = 'view previous', group = 'tag'}),
  awful.key(
    {modkey}, 'Right', awful.tag.viewnext,
      {description = 'view next', group = 'tag'}),
  awful.key(
    {modkey}, 'Escape', awful.tag.history.restore,
      {description = 'go back', group = 'tag'}),
  awful.key(
    {modkey}, 'p', function() awful.screen.focus_relative(-1) end,
      {description = 'focus the next screen', group = 'screen'}),
  awful.key(
    {modkey}, 'o', function() awful.screen.focus_relative(1) end,
      {description = 'focus the previous screen', group = 'screen'}), -- Layout
  awful.key(
    {modkey}, 's', function() awful.layout.set(awful.layout.suit.max) end,
      {description = 'select max', group = 'layout'}),
  awful.key(
    {modkey, 'Shift'}, 's',
      function() awful.layout.set(awful.layout.suit.floating) end,
      {description = 'select floating', group = 'layout'}),
  awful.key(
    {modkey}, 'a', function() awful.layout.set(awful.layout.suit.tile) end,
      {description = 'select tile', group = 'layout'}),
  awful.key(
    {modkey, 'Shift'}, 'a',
      function() awful.layout.set(awful.layout.suit.spiral.dwindle) end,
      {description = 'select dwindle', group = 'layout'}), -- Client
  awful.key(
    {modkey}, 'l', function() awful.tag.incmwfact(0.05) end,
      {description = 'increase master width factor', group = 'layout'}),
  awful.key(
    {modkey}, 'h', function() awful.tag.incmwfact(-0.05) end,
      {description = 'decrease master width factor', group = 'layout'}),
  awful.key(
    {modkey, 'Shift'}, 'h', function() awful.client.incwfact(0.05) end,
      {description = 'increase the clients width', group = 'layout'}),
  awful.key(
    {modkey, 'Shift'}, 'l', function() awful.client.incwfact(-0.05) end,
      {description = 'decrease the clients width', group = 'layout'}),
  awful.key(
    {modkey, 'Control'}, 'h', function() awful.tag.incncol(1, nil, true) end,
      {description = 'increase the number of columns', group = 'layout'}),
  awful.key(
    {modkey, 'Control'}, 'l', function() awful.tag.incncol(-1, nil, true) end,
      {description = 'decrease the number of columns', group = 'layout'}),
  awful.key(
    {modkey}, 'space', function() awful.layout.inc(1) end,
      {description = 'select next', group = 'layout'}),
  awful.key(
    {modkey, 'Shift'}, 'space', function() awful.layout.inc(-1) end,
      {description = 'select previous', group = 'layout'}),
  awful.key(
    {modkey}, 'j', function() awful.client.focus.byidx(1) end,
      {description = 'focus next by index', group = 'client'}),
  awful.key(
    {modkey}, 'k', function() awful.client.focus.byidx(-1) end,
      {description = 'focus previous by index', group = 'client'}),
  awful.key(
    {modkey, 'Shift'}, 'j', function() awful.client.swap.byidx(1) end,
      {description = 'swap with next client by index', group = 'client'}),
  awful.key(
    {modkey, 'Shift'}, 'k', function() awful.client.swap.byidx(-1) end,
      {description = 'swap with previous client by index', group = 'client'}),
  awful.key(
    {modkey}, 'u', awful.client.urgent.jumpto,
      {description = 'jump to urgent client', group = 'client'}),
  awful.key(
    {modkey}, 'Tab', function()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end, {description = 'go back', group = 'client'}),
  awful.key(
    {modkey}, 'b', function()
      beautiful.titlebar_enabled = not beautiful.titlebar_enabled
      if not beautiful.titlebar_enabled then
        beautiful.border_focus = '#666666' .. '30'
        beautiful.border_width = dpi(0)
      else
        beautiful.border_focus = beautiful.background
        beautiful.border_width = dpi(0)
      end
      awful.layout.inc(1)
      awful.layout.inc(-1)
    end, {description = 'toggle title bar', group = 'client'}),
  -- My Progamm launchers
  awful.key(
    {modkey}, 'Return', function() awful.spawn(apps.default.terminal) end,
      {description = 'open default terminal', group = 'launcher'}),
  awful.key(
    {'Control', 'Shift'}, 'Escape',
      function() awful.spawn(apps.default.terminal .. ' ' .. 'bashtop') end,
      {description = 'open system monitor', group = 'launcher'}),
  awful.key(
    {modkey}, 'd', function()
      local focused = awful.screen.focused()

      if focused.left_panel then
        focused.left_panel:HideDashboard()
        focused.left_panel.opened = false
      end
      if focused.right_panel then
        focused.right_panel:HideDashboard()
        focused.right_panel.opened = false
      end
      awful.util.spawn(apps.default.rofiappmenu)
    end, {description = 'open application drawer', group = 'launcher'}),
  awful.key(
    {modkey}, 'y', function()
      drop(
        apps.default.terminal,
          {width = 0.5, minwidth = 720, height = 0.5, vert = 'center'})
    end, {description = 'toggle dropdown terminal', group = 'launcher'}),
  awful.key(
    {modkey}, 't', function()
      drop(
        apps.default.terminal .. ' -e pulsemixer',
          {width = 0.5, minwidth = 720, height = 0.5, vert = 'center'})
    end, {description = 'toggle dropdown pulsemixer', group = 'launcher'}),
  awful.key(
    {modkey, 'Shift'}, 'd', function() awful.spawn('drun_rofi 1380x780') end,
      {description = 'open rofi as application starter', group = 'launcher'}),
  awful.key(
    {modkey, 'Control'}, 'm', function() awful.spawn('thunderbird') end,
      {description = 'open the mail client', group = 'launcher'}),
  awful.key(
    {modkey, 'Control'}, 'i',
      function() awful.spawn(apps.default.web_browser) end,
      {description = 'open firefox', group = 'launcher'}),
  awful.key(
    {modkey, 'Control'}, 'c',
      function() awful.spawn(apps.default.alt_web_browser) end,
      {description = 'open firefox alternative', group = 'launcher'}),
  awful.key(
    {modkey, 'Control'}, 'p',
      function() awful.spawn(apps.default.password_manager) end,
      {description = 'open Keepass XC', group = 'launcher'}),
  awful.key(
    {modkey, 'Control'}, 'f',
      function() awful.spawn(apps.default.gui_file_manager) end,
      {description = 'open file browser', group = 'launcher'}),
  awful.key(
    {modkey, 'Control'}, 'v',
      function() awful.spawn(apps.default.gui_ide) end,
      {description = 'open VS Code', group = 'launcher'}),
  awful.key(
    {modkey, 'Control'}, 'w', function() awful.spawn('signal-desktop') end,
      {description = 'open Signal messenger', group = 'launcher'}),
  awful.key(
    {modkey, 'Control'}, 'g', function() awful.spawn('gajim') end,
      {description = 'open Gajim messenger', group = 'launcher'}),
  awful.key(
    {modkey, 'Control'}, 's', function() awful.spawn('spotify') end,
      {description = 'open Spotify music player', group = 'launcher'}),
  awful.key(
    {modkey, 'Control'}, 'd', function() awful.spawn('discord') end,
      {description = 'open Discord', group = 'launcher'}),
  awful.key(
    {modkey,          }, 'n', function() awesome.emit_signal("widget::notif_osd:toggle") end,
      {description = 'Toggle notification popup', group = 'hotkeys'}),
  awful.key(
    {modkey,          }, 'c', function() awesome.emit_signal("widget::calendar_osd:toggle") end,
      {description = 'Toggle calendar popup', group = 'hotkeys'}),
  awful.key(
    {}, 'XF86MonBrightnessUp',
      function() awesome.emit_signal('widget::brightness:change', 10) end,
      {description = 'increase brightness by 10%', group = 'hotkeys'}),
  awful.key(
    {}, 'XF86MonBrightnessDown',
      function() awesome.emit_signal('widget::brightness:change', -10) end,
      {description = 'decrease brightness by 10%', group = 'hotkeys'}),
  awful.key(
    {}, 'XF86AudioRaiseVolume',
      function() awesome.emit_signal('widget::volume:change', 5) end,
      {description = 'increase volume up by 5%', group = 'hotkeys'}),
  awful.key(
    {}, 'XF86AudioLowerVolume',
      function() awesome.emit_signal('widget::volume:change', -5) end,
      {description = 'decrease volume up by 5%', group = 'hotkeys'}),
  awful.key(
    {}, 'XF86AudioMute',
      function() awesome.emit_signal('widget::volume:toggle_mute') end,
      {description = 'toggle mute', group = 'hotkeys'}),
  awful.key(
    {}, 'XF86AudioNext', function() awful.spawn('playerctl next', false) end,
      {description = 'next music', group = 'hotkeys'}),
  awful.key(
    {}, 'XF86AudioPrev', function() awful.spawn('playerctl prev', false) end,
      {description = 'previous music', group = 'hotkeys'}),
  awful.key(
    {}, 'XF86AudioPlay',
      function() awful.spawn('playerctl play-pause', false) end,
      {description = 'play/pause music', group = 'hotkeys'}),
  awful.key(
    {}, 'XF86AudioMicMute',
      function() awful.spawn('amixer set Capture toggle', false) end,
      {description = 'mute microphone', group = 'hotkeys'}),
  awful.key(
    {modkey}, 'm', function()
      for _, c in ipairs(client.get()) do
        -- do something
        c:raise()
        c.fullscreen = false
        c.maximized = false
        c.minimized = false

      end
    end, {
      description = 'Raise all minimized windows of current screen',
      group = 'Clients'
    }), awful.key(
    {modkey}, '.', function()
      -- tag_view_nonempty(-1)
      local focused = awful.screen.focused()
      for i = 1, #focused.tags do
        awful.tag.viewidx(-1, focused)
        if #focused.clients > 0 then
          return
        end
      end
    end, {description = 'view previous non-empty tag', group = 'tag'}),
  awful.key(
    {modkey, 'Shift'}, '.', function()
      -- tag_view_nonempty(1)
      local focused = awful.screen.focused()
      for i = 1, #focused.tags do
        awful.tag.viewidx(1, focused)
        if #focused.clients > 0 then
          return
        end
      end
    end, {description = 'view next non-empty tag', group = 'tag'}),
  awful.key(
    {}, 'Print', function()
      awful.spawn.easy_async_with_shell(
        apps.bins.full_screenshot, function() end)
    end, {description = 'fullscreen screenshot', group = 'Utility'}),
  awful.key(
    {modkey, 'Shift'}, 's', function()
      awful.spawn.easy_async_with_shell(
        apps.bins.area_screenshot, function() end)
    end, {description = 'area/selected screenshot', group = 'Utility'}),
  awful.key(
    {modkey}, 'F2', function()
      -- awful.spawn(apps.default.lock, false)
      awesome.emit_signal("module::lock_screen:show")
    end,
      {description = 'lock the screen', group = 'Utility'}),
  awful.key(
    {modkey}, 'F3', function() awful.spawn('flameshot gui') end,
      {description = 'screenshot with flameshot', group = 'function'}),
  awful.key(
    {modkey}, 'F4', function() awesome.emit_signal("module::exit_screen:show") end,
      {description = 'show exit screen', group = 'function'}),
  awful.key(
    {modkey}, 'F7', function() awful.spawn('displayselect') end,
      {description = 'open display selection', group = 'function'}),
  awful.key(
    {modkey}, 'F1', function()
      local focused = awful.screen.focused()

      if focused.right_panel and focused.right_panel.visible then
        focused.right_panel.visible = false
      end
      focused.left_panel:toggle(true)
    end, {description = 'open sidebar and global search', group = 'launcher'}),
  awful.key(
    {modkey}, 'n',
      function()
        _G.awesome.emit_signal('module::dashboard_screen:show')
      end, {description = 'open today pane', group = 'launcher'}))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
  local descr_view, descr_toggle, descr_move, descr_toggle_focus
  if i == 1 or i == 9 then
    descr_view = {description = 'view tag #', group = 'tag'}
    descr_toggle = {description = 'toggle tag #', group = 'tag'}
    descr_move = {description = 'move focused client to tag #', group = 'tag'}
    descr_toggle_focus = {
      description = 'toggle focused client on tag #',
      group = 'tag'
    }
  end
  globalKeys = awful.util.table.join(
    globalKeys, -- View tag only.
    awful.key(
      {modkey}, '#' .. i + 9, function()
        local focused = awful.screen.focused()
        local tag = focused.tags[i]
        if tag then
          tag:view_only()
        end
      end, descr_view), -- Toggle tag display.
    awful.key(
      {modkey, 'Control'}, '#' .. i + 9, function()
        local focused = awful.screen.focused()
        local tag = focused.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end, descr_toggle), -- Move client to tag.
    awful.key(
      {modkey, 'Shift'}, '#' .. i + 9, function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end, descr_move), -- Toggle tag on focused client.
    awful.key(
      {modkey, 'Control', 'Shift'}, '#' .. i + 9, function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end, descr_toggle_focus))
end

return globalKeys
