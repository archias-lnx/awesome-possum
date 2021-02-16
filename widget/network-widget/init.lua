local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local naughty = require('naughty')
local configuration = require('configuration')

local dpi = require('beautiful').xresources.apply_dpi
local clickable_image = require('widget.clickable-image')
local callbacks = require('widget.callbacks')

local apps = require('configuration.apps')
local icons = require('theme.icons')

local watch = awful.widget.watch
local update_interval = configuration.update_interval or 5
local awesome = _G.awesome
local mouse = _G.mouse

-- local variables
local wifi_interface = nil
local eth_interface = nil
local vpn_connection = false
local eth_connection = false
local wifi_connection = false
local essid = 'N/A'
local wifi_strength = 0
local alert = false
local update_interval = configuration.update_interval or 5

-- return type: table with the widget build function and some additional information
local network_widget = {}
network_widget.watch_active = false
network_widget.created_widgets = {}

-- toggle actions
network_widget.toggle_wifi = function()
  if wifi_connection then
    awful.spawn('nmcli dev disconnect ' .. wifi_interface)
  else
    awful.spawn('nmcli dev connect ' .. wifi_interface)
  end
  network_widget.update_function()
  awesome.emit_signal('widget:wifi:updateicon')
end

network_widget.toggle_eth = function()
  if eth_connection then
    awful.spawn('nmcli dev disconnect ' .. eth_interface)
  else
    awful.spawn('nmcli dev connect ' .. eth_interface)
  end
  network_widget.update_function()
  awesome.emit_signal('widget:wifi:updateicon')
end

network_widget.toggle_vpn = function()
  if vpn_connection then
    awful.spawn('nmcli con down ' .. apps.default.vpn)
  else
    awful.spawn('nmcli con up ' .. apps.default.vpn)
    -- TODO: do not use default vpn but give a list with joices
  end
  network_widget.update_function()
  awesome.emit_signal('widget:wifi:updateicon')
end

-- notification
network_widget.notify_connection = function(notif)
  local n_message = ''
  local n_title = ''
  local n_icon = icons.widget.network.notify_off
  if notif == 'vpn off' then
    n_message = 'Disconnected from VPN Connection'
    n_title = 'VPN Connection Off'
    n_icon = icons.widget.network.notify_vpn_off
  elseif notif == 'vpn on' then
    n_message = 'New VPN Connection'
    n_title = 'VPN Connection'
    n_icon = icons.widget.network.notify_vpn_on
  elseif notif == 'no internet' then
    n_message = 'Network connection but no Internet'
    n_title = 'No Internet Access'
    n_icon = icons.widget.network.notify_off
  elseif notif == 'new eth' then
    n_message = 'Ethernet connection established with ' .. eth_interface
    n_title = 'New Ethernet Connection'
    n_icon = icons.widget.network.notify_eth
  elseif notif == 'new wifi' then
    n_message = 'Connection with ' .. essid .. ' established'
    n_title = 'New Wifi Connection'
    n_icon = icons.widget.network.notify_wifi
  elseif notif == 'all off' then
    n_message = 'No Network connection up'
    n_title = 'No Network Connection'
    n_icon = icons.widget.network.notify_off
  else
    n_message = 'Something went wrong'
    n_title = 'Network Notification'
  end
  naughty.notification(
    {
      message = n_message,
      title = n_title,
      app_name = 'System Notification',
      icon = n_icon
    })
end

network_widget.update_function = function()
  -- TODO: implement some status change check so notifications come not all the time + check how to best get the ssid directly so it appears in the notification
  awful.spawn.easy_async_with_shell(
    [[nmcli]], function(stdout)
      local nmcli_output = stdout
      if string.match(nmcli_output, 'Wired connection') then
        -- no wifi --> check ethernet !!
        if eth_connection == false then
          network_widget.notify_connection('new eth')
        end
        wifi_connection = false
        eth_connection = true
      elseif string.match(nmcli_output, 'connected to ') then
        awful.spawn
          .easy_async_with_shell( -- 'iw dev ' .. apps.default.wifi_interface .. ' link',
          'iw dev ', function(stdout)
            essid = stdout:match('ssid (.-)\n')
            if (essid == nil) then
              essid = 'N/A'
            end
          end)
        -- now check the speed of the wifi
        awful.spawn.easy_async_with_shell(
          [[awk 'NR==3 {printf "%3.0f" ,($3/70)*100}' /proc/net/wireless]],
            function(stdout)
              if stdout == '' or stdout == nil then
                wifi_strength = 0
              else
                wifi_strength = tonumber(stdout)
              end
            end)
        -- notify here so we have the ssid already
        if wifi_connection == false then
          network_widget.notify_connection('new wifi')
        end
        wifi_connection = true
        eth_connection = false
      else
        if wifi_connection or eth_connection then
          network_widget.notify_connection('all off')
        end
        wifi_connection = false
        eth_connection = false
      end
      collectgarbage('collect')
    end)

  if wifi_connection or eth_connection then
    -- now check, if we can reach the dns server
    alert = false
    -- awful.spawn.easy_async_with_shell(
    --   [[ ping -q -w 2 -c2 8.8.8.8 | grep -o "100% packet loss" ]],
    --     function(stdout)
    --       if stdout and stdout ~= '' then
    --         if alert == false then
    --           network_widget.notify_connection('no internet')
    --         end
    --         alert = true
    --       else
    --         alert = false
    --       end
    --     end)
    -- now check, if we are connected via vpn
    awful.spawn.easy_async_with_shell(
      'nmcli', function(stdout)
        if string.match(stdout, 'VPN connection') then
          if vpn_connection == false then
            network_widget.notify_connection('vpn on')
          end
          vpn_connection = true
        else
          if vpn_connection == true then
            network_widget.notify_connection('vpn off')
          end
          vpn_connection = false
        end
      end)
  end
  -- TODO evtl auch nur bei status change!
  awesome.emit_signal('widget:wifi:updateicon')
end

network_widget.start_watch = function()
  network_widget.watch_active = true
  -- Status and watch function here
  awful.spawn.easy_async_with_shell(
    'ls /sys/class/net | grep wl', function(stdout) wifi_interface = stdout end)
  awful.spawn.easy_async_with_shell(
    'ls /sys/class/net | grep en', function(stdout) eth_interface = stdout end)

  -- Update Function
  watch(
    [[ls]], update_interval, function() network_widget.update_function() end)
end

network_widget.build = function(args)

  -- Buttons
  local table = gears.table.join(
    awful.button(
      {}, 1, nil,
        function() awful.spawn(apps.default.network_manager, false) end),
      awful.button({}, 3, nil, function() network_widget.toggle_vpn() end))
  local widget_button, imagebox = clickable_image(
    args, icons.widget.network.no_network, table)

  -- Tooltip
  awful.tooltip(
    {
      objects = {widget_button},
      mode = 'outside',
      align = 'top',
      preferred_alignments = {'middle'},
      delay_show = 1,
      timer_function = function()
        local popString = ''
        if eth_connection then
          popString = 'Connected with Ethernet'
        elseif wifi_connection then
          popString = 'Connected to: ' .. essid .. '\nWiFi-strength: ' ..
                        tostring(wifi_strength) .. '%'
        else
          popString = 'No network connection'
        end
        if alert then
          popString = popString .. '\nNo Internet'
        elseif vpn_connection then
          popString = popString .. '\nActive VPN Connection'
        end
        return popString
      end,
      preferred_positions = {'right', 'left', 'top', 'bottom'},
      margin_leftright = dpi(8),
      margin_topbottom = dpi(8)
    })

  -- icon update
  local update_icon = function()
    local icon_string = ''
    if wifi_connection then
      icon_string = 'wifi_'
      if wifi_strength < 25 then
        icon_string = icon_string .. '1'
      elseif wifi_strength < 50 then
        icon_string = icon_string .. '2'
      elseif wifi_strength < 75 then
        icon_string = icon_string .. '3'
      else
        icon_string = icon_string .. '4'
      end
    elseif eth_connection then
      icon_string = 'eth_on'
    else
      imagebox.icon:set_image(icons.widget.network.no_network)
      return
    end

    if alert then
      icon_string = icon_string .. '_alert'
    elseif vpn_connection then
      icon_string = icon_string .. '_lock'
    end
    imagebox.icon:set_image(icons.widget.network[icon_string])
  end

  awesome.connect_signal('widget:wifi:updateicon', function() update_icon() end)

  if not network_widget.watch_active then
    network_widget.start_watch()
  end
  -- TODO warum geht das hier nicht?!?!
  -- network_widget.created_widgets.insert(widget_button)

  return widget_button
end

-- Dashboard
network_widget.build_dashboard = function(args)
  local widget_layout = function(inverse)
    if args.orientation == 'horizontal' then
      if inverse then
        return wibox.layout.fixed.vertical()
      end
      return wibox.layout.fixed.horizontal()
    else
      if inverse then
        return wibox.layout.fixed.horizontal()
      end
      return wibox.layout.fixed.vertical()
    end
  end

  local build_dasboard_element = function(init_image, icon_action,
    toggle_icon_action)
    local args = {callback = callbacks.zoom, tooltip = false}
    local dashboard_button, dashboard_icon =
      clickable_image(args, init_image, icon_action)
    local dashboard_text = wibox.widget {
      text = 'Off',
      font = 'SF Pro Text Regular 11',
      align = 'left',
      widget = wibox.widget.textbox
    }
    local dashboard_toggle_button, dashboard_toggle_icon =
      clickable_image(args, icons.toggled_off, toggle_icon_action)

    -- TODO : build it also as a vertical widget
    local dashboard_widget = wibox.widget {
      {
        {
          {
            dashboard_button,
            top = dpi(4),
            bottom = dpi(4),
            right = dpi(20),
            widget = wibox.container.margin
          },
          layout = wibox.layout.fixed.horizontal
        },
        dashboard_text,
        {
          {
            dashboard_toggle_button,
            top = dpi(2),
            bottom = dpi(2),
            widget = wibox.container.margin
          },
          layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.horizontal
      },
      left = dpi(14),
      right = dpi(24),
      forced_height = dpi(48),
      widget = wibox.container.margin
    }

    return {
      icon = dashboard_icon,
      text = dashboard_text,
      toggle_icon = dashboard_toggle_icon,
      widget = dashboard_widget
    }
  end
  local dashboard_wifi = build_dasboard_element(
    icons.widget.network.wifi_off,
      function() awful.spawn(apps.default.terminal .. ' -e nmtui') end,
      function() network_widget.toggle_wifi() end)
  local dashboard_eth = build_dasboard_element(
    icons.widget.network.eth_off,
      function() awful.spawn(apps.default.terminal .. ' -e nmtui') end,
      function() network_widget.toggle_eth() end)
  local dashboard_vpn = build_dasboard_element(
    icons.widget.network.vpn_off,
      function() awful.spawn(apps.default.terminal .. ' -e nmtui') end,
      function() network_widget.toggle_vpn() end)

  local dashboard = wibox.widget {
    layout = widget_layout(true),
    {
      {
        wibox.widget {
          text = 'Connection Editor',
          font = 'SF Pro Text Regular 12',
          align = 'left',
          valign = 'center',
          widget = wibox.widget.textbox
        },
        left = dpi(24),
        right = dpi(24),
        widget = wibox.container.margin
      },
      bg = beautiful.groups_title_bg,
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(
          cr, width, height, true, true, false, false, beautiful.groups_radius)
      end,
      forced_height = dpi(35),
      widget = wibox.container.background
    },
    {
      dashboard_wifi.widget,
      bg = beautiful.groups_bg,
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(
          cr, width, height, false, false, false, false, beautiful.groups_radius)
      end,
      forced_height = dpi(48),
      widget = wibox.container.background
    },
    {
      dashboard_eth.widget,
      bg = beautiful.groups_bg,
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(
          cr, width, height, false, false, false, false, beautiful.groups_radius)
      end,
      forced_height = dpi(48),
      widget = wibox.container.background
    },
    {
      dashboard_vpn.widget,
      bg = beautiful.groups_bg,
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(
          cr, width, height, false, false, true, true, beautiful.groups_radius)
      end,
      forced_height = dpi(48),
      widget = wibox.container.background
    }
  }

  local update_icon = function()
    local icon_string = ''
    if wifi_connection then
      icon_string = 'wifi_'
      if wifi_strength < 25 then
        icon_string = icon_string .. '1'
      elseif wifi_strength < 50 then
        icon_string = icon_string .. '2'
      elseif wifi_strength < 75 then
        icon_string = icon_string .. '3'
      else
        icon_string = icon_string .. '4'
      end
      if alert then
        icon_string = icon_string .. '_alert'
      end
      dashboard_wifi.text:set_text(
        essid .. ': ' .. tostring(wifi_strength) .. ' %')
      dashboard_wifi.toggle_icon.icon:set_image(icons.widget.toggled_on)
      dashboard_wifi.icon.icon:set_image(icons.widget.network[icon_string])
    else
      dashboard_wifi.text:set_text('No Wifi')
      dashboard_wifi.toggle_icon.icon:set_image(icons.widget.toggled_off)
      dashboard_wifi.icon.icon:set_image(icons.widget.network.wifi_off)
    end
    if eth_connection then
      icon_string = 'eth_on'
      if alert then
        icon_string = icon_string .. '_alert'
      end
      dashboard_eth.text:set_text('Wired Connection')
      dashboard_eth.toggle_icon.icon:set_image(icons.widget.toggled_on)
      dashboard_eth.icon.icon:set_image(icons.widget.network[icon_string])
    else
      dashboard_eth.text:set_text('No Wired Connection')
      dashboard_eth.toggle_icon.icon:set_image(icons.widget.toggled_off)
      dashboard_eth.icon.icon:set_image(icons.widget.network.eth_off)
    end
    if vpn_connection then
      dashboard_vpn.text:set_text('Connected to ' .. apps.default.vpn)
      dashboard_vpn.toggle_icon.icon:set_image(icons.widget.toggled_on)
      dashboard_vpn.icon.icon:set_image(icons.widget.network.vpn_on)
    else
      dashboard_vpn.text:set_text('No VPN Connection')
      dashboard_vpn.toggle_icon.icon:set_image(icons.widget.toggled_off)
      dashboard_vpn.icon.icon:set_image(icons.widget.network.vpn_off)
    end
  end

  awesome.connect_signal('widget:wifi:updateicon', function() update_icon() end)

  if not network_widget.watch_active then
    network_widget.start_watch()
  end

  return dashboard
end

return network_widget
